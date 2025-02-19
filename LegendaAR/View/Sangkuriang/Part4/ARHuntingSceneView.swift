import SwiftUI
import ARKit
import RealityKit
import Combine

// MARK: - Protocol
protocol ARViewControllerDelegate: AnyObject {
    func arViewController(_ controller: ARViewController, didTapSangkuriang entity: Entity)
}

// MARK: - Main View
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
            ARViewControllerRepresentable(
                isSangkuriangTappable: $isSangkuriangTappable,
                onSangkuriangTapped: playDialogue
            )
            .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack {
                    // Top Bar
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
                        
                        CloseButton(isPresented: $showHuntingView)
                            .padding(.trailing, 20)
                            .onTapGesture {
                                audioManager.stopAudio()
                                showHuntingView = false
                            }
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 10)
                    
                    Spacer()
                    
                    // Warning Text
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
                    
                    // Dialogue Text
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
        .onAppear(perform: startScene)
        .onDisappear {
            audioManager.stopAudio()
        }
        .fullScreenCover(isPresented: $navigateToNextScene) {
            HuntingGameView(showGameView: $navigateToNextScene)
        }
        .forceLandscape()
    }
    
    private func startScene() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                isWarningVisible = true
                isSangkuriangTappable = true
            }
        }
    }
    
    private func playDialogue() {
        withAnimation {
            isWarningVisible = false
            isSangkuriangTappable = false
            isTextVisible = true
        }
        
        audioManager.playAudio(filename: "Sangkuriang_Hunt")
        DialogueManager.playDialogue(
            text: dialogueText,
            audio: "Sangkuriang_Hunt",
            audioManager: audioManager,
            displayedText: $displayedText,
            isTextVisible: $isTextVisible
        ) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    isNextButtonVisible = true
                }
            }
        }
    }
}

// MARK: - AR View Controller
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
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        setupCoachingOverlay()
        setupPlaneDetection()
        setupGestures()
    }
    
    private func setupCoachingOverlay() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.session = arView.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.frame = arView.bounds
        arView.addSubview(coachingOverlay)
    }
    
    private func setupPlaneDetection() {
        arView.session.delegate = self
        arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] _ in
            self?.updateScene()
        }.store(in: &cancellables)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tapGesture)
    }
    
    private func updateScene() {
        guard sangkuriangEntity == nil,
              let query = arView.makeRaycastQuery(from: arView.center,
                                                allowing: .estimatedPlane,
                                                alignment: .horizontal),
              let result = arView.session.raycast(query).first else { return }
        
        placeSangkuriang(at: result)
    }
    
    private func placeSangkuriang(at raycastResult: ARRaycastResult) {
        Entity.loadModelAsync(named: "Sangkuriang_Jalan")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to load Sangkuriang model: \(error)")
                    }
                },
                receiveValue: { [weak self] entity in
                    self?.setupSangkuriangEntity(entity, at: raycastResult)
                }
            )
            .store(in: &cancellables)
    }
    
    private func setupSangkuriangEntity(_ entity: Entity, at raycastResult: ARRaycastResult) {
        sangkuriangEntity = entity
        
        let anchorEntity = AnchorEntity(world: raycastResult.worldTransform)
        entity.position = .zero
        entity.scale = SIMD3(x: 1.0, y: 1.0, z: 1.0)
        
        if let animation = entity.availableAnimations.first {
            entity.playAnimation(animation.repeat(count: .max))
        }
        
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: arView)
        if let entity = arView.entity(at: location), entity == sangkuriangEntity {
            delegate?.arViewController(self, didTapSangkuriang: entity)
        }
    }
}

// MARK: - AR Session Delegate
extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR Session failed: \(error)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("AR Session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("AR Session interruption ended")
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
}

// MARK: - SwiftUI Representable
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
