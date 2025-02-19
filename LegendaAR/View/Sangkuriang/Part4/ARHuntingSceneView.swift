import SwiftUI
import ARKit
import RealityKit
import Combine

struct ARHuntingSceneView: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var displayedText = ""
    @State private var isTextVisible = false
    @State private var isWarningVisible = false
    @State private var isSangkuriangTappable = false
    @State private var isNextButtonVisible = false
    @State private var navigateToNextScene = false
    @Environment(\.presentationMode) var presentationMode
    @Binding var showHuntingView: Bool
    
    let warningText = "Sangkuriang wants to talk, tap Sangkuriang"
    let dialogueText = "I couldn't find a deer... Maybe Tumang's heart will do?"
    
    var body: some View {
        ZStack {
            // AR View takes full screen
            ARViewControllerRepresentable(
                isSangkuriangTappable: $isSangkuriangTappable,
                onSangkuriangTapped: playDialogue
            )
            .edgesIgnoringSafeArea(.all)
            .ignoresSafeArea()
            
            // Overlay content
            GeometryReader { geometry in
                VStack {
                    // Top Bar with Back Button
                    HStack {
                        Button(action: {
                            audioManager.stopAudio()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        // Close button
                        CloseButton(isPresented: $showHuntingView)
                            .padding(.trailing, 20)
                            .onTapGesture {
                                audioManager.stopAudio()
                                showHuntingView = false
                            }
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 10)
                    
                    Spacer()
                    
                    // Warning or Dialogue Text
                    if isWarningVisible {
                        Text(warningText)
                            .font(.headline)
                            .fontWeight(.medium)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .transition(.opacity)
                            .animation(.easeInOut, value: isWarningVisible)
                    }
                    
                    if isTextVisible {
                        DialogueTextView(text: displayedText)
                            .frame(width: geometry.size.width * 0.95)
                            .transition(.opacity)
                            .animation(.easeInOut, value: isTextVisible)
                    }
                    
                    // Next Button
                    if isNextButtonVisible {
                        NextButton(title: "Next") {
                            audioManager.stopAudio()
                            navigateToNextScene = true
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            startScene()
        }
        .onDisappear {
            audioManager.stopAudio()
        }
        .forceLandscape()
    }
    
    private func startScene() {
        // Show warning after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                isWarningVisible = true
                isSangkuriangTappable = true
            }
        }
    }
    
    private func playDialogue() {
        // Hide warning and show dialogue
        withAnimation {
            isWarningVisible = false
            isSangkuriangTappable = false
            isTextVisible = true
        }
        
        // Play audio and show dialogue
        audioManager.playAudio(filename: "Sangkuriang_Hunt")
        DialogueManager.playDialogue(
            text: dialogueText,
            audio: "Sangkuriang_Hunt",
            audioManager: audioManager,
            displayedText: $displayedText,
            isTextVisible: $isTextVisible
        ) {
            // Show next button after dialogue
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    isNextButtonVisible = true
                }
            }
        }
    }
}

// AR View Controller
struct ARViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var isSangkuriangTappable: Bool
    var onSangkuriangTapped: () -> Void
    
    func makeUIViewController(context: Context) -> ARViewController {
        let arViewController = ARViewController()
        arViewController.delegate = context.coordinator
        return arViewController
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        context.coordinator.isSangkuriangTappable = isSangkuriangTappable
        context.coordinator.onSangkuriangTapped = onSangkuriangTapped
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isSangkuriangTappable: isSangkuriangTappable, onSangkuriangTapped: onSangkuriangTapped)
    }
    
    class Coordinator: NSObject, ARViewControllerDelegate {
        var isSangkuriangTappable: Bool
        var onSangkuriangTapped: () -> Void
        
        init(isSangkuriangTappable: Bool, onSangkuriangTapped: @escaping () -> Void) {
            self.isSangkuriangTappable = isSangkuriangTappable
            self.onSangkuriangTapped = onSangkuriangTapped
        }
        
        func arViewController(_ controller: ARViewController, didTapSangkuriang entity: Entity) {
            if isSangkuriangTappable {
                onSangkuriangTapped()
            }
        }
    }
}

// Protocol for AR View Controller delegate
protocol ARViewControllerDelegate: AnyObject {
    func arViewController(_ controller: ARViewController, didTapSangkuriang entity: Entity)
}

// AR View Controller
class ARViewController: UIViewController {
    weak var delegate: ARViewControllerDelegate?
    private var arView: ARView!
    private var sangkuriangEntity: Entity?
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
    }
    
    private func setupAR() {
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
        
        // Load and place Sangkuriang 3D model
        loadSangkuriang()
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tapGesture)
    }
    
    private func loadSangkuriang() {
        // Load Sangkuriang model asynchronously
        Entity.loadModelAsync(named: "Sangkuriang_Jalan")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Failed to load Sangkuriang model: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] entity in
                self?.sangkuriangEntity = entity
                
                // Position the entity in the scene
                entity.position = SIMD3(x: 0, y: 0, z: -2)
                
                // Play walking animation if available
                if let animation = entity.availableAnimations.first {
                    // Play the animation in a loop
                    entity.playAnimation(animation.repeat(count: .max))
                }
                
                // Add to scene
                let anchorEntity = AnchorEntity(world: entity.position)
                anchorEntity.addChild(entity)
                self?.arView.scene.addAnchor(anchorEntity)
            })
            .store(in: &cancellables)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: arView)
        
        if let entity = arView.entity(at: location), entity == sangkuriangEntity {
            delegate?.arViewController(self, didTapSangkuriang: entity)
        }
    }
}

struct ARHuntingSceneView_Previews: PreviewProvider {
    static var previews: some View {
        ARHuntingSceneView(showHuntingView: .constant(true))
    }
}
