import SwiftUI
import RealityKit
import ARKit
import Combine

// MARK: - Main View
struct ShipPuzzleGameView: View {
    @StateObject private var arViewModel = ARViewModel()
    @State private var showSuccess = false
    @State private var showInstructions = true
    @Binding var showPuzzleView: Bool
    
    var body: some View {
        ZStack {
            ARViewContainer(arViewModel: arViewModel)
                .edgesIgnoringSafeArea(.all)
            
            // Scanning overlay
            if arViewModel.scanningFloor {
                ScanningOverlayView()
            }
            
            VStack {
                // Top Bar
                HStack {
                    Button(action: { showPuzzleView = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: { arViewModel.resetGame() }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Text("Parts: \(arViewModel.placedParts)/\(arViewModel.totalParts)")
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
                
                if !showSuccess {
                    // Parts selection
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(arViewModel.availableParts) { part in
                                ShipPartButton(part: part) {
                                    arViewModel.selectPart(part)
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                    }
                }
            }
            
            if showInstructions {
                EnhancedInstructionsView {
                    showInstructions = false
                }
            }
            
            if showSuccess {
                SuccessView {
                    showPuzzleView = false
                    arViewModel.resetGame()
                }
            }
        }
        .onChange(of: arViewModel.placedParts) { newValue in
            if newValue == arViewModel.totalParts {
                showSuccess = true
            }
        }
    }
}

// MARK: - AR View Container
struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arViewModel.arView = arView
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.delegate = context.coordinator
        arView.session.run(config)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(arViewModel: arViewModel)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var arViewModel: ARViewModel
        
        init(arViewModel: ARViewModel) {
            self.arViewModel = arViewModel
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let planeAnchor = anchor as? ARPlaneAnchor {
                    arViewModel.handlePlaneDetection(planeAnchor)
                }
            }
        }
        
        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = recognizer.view as? ARView else { return }
            let location = recognizer.location(in: arView)
            
            if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
                arViewModel.handleTap(at: result.worldTransform)
            }
        }
    }
}

// MARK: - View Model
class ARViewModel: ObservableObject {
    @Published var placedParts = 0
    @Published var selectedPartId: Int?
    @Published var scanningFloor = true
    @Published var availableParts: [ShipPart] = []
    
    let totalParts = 5
    weak var arView: ARView?
    private var shipGuidelineAnchor: AnchorEntity?
    
    init() {
        setupParts()
    }
    
    private func setupParts() {
        availableParts = [
            ShipPart(id: 1, name: "Base", shape: .box, color: .red,
                     position: SIMD3<Float>(0, 0, 0)),
            ShipPart(id: 2, name: "Middle", shape: .sphere, color: .blue,
                     position: SIMD3<Float>(0, 0.2, 0)),
            ShipPart(id: 3, name: "Top", shape: .tallBox, color: .green,
                     position: SIMD3<Float>(0, 0.4, 0)),
            ShipPart(id: 4, name: "Left Wing", shape: .flatBox, color: .yellow,
                     position: SIMD3<Float>(-0.2, 0.2, 0)),
            ShipPart(id: 5, name: "Right Wing", shape: .flatBox, color: .purple,
                     position: SIMD3<Float>(0.2, 0.2, 0))
        ]
    }
    
    func handlePlaneDetection(_ planeAnchor: ARPlaneAnchor) {
        DispatchQueue.main.async {
            self.scanningFloor = false
            self.createShipGuideline(at: planeAnchor.transform)
        }
    }
    
    private func createShipGuideline(at transform: simd_float4x4) {
        guard let arView = arView else { return }
        
        // Remove existing guideline if any
        shipGuidelineAnchor?.removeFromParent()
        
        // Create new guideline
        let anchor = AnchorEntity(world: transform)
        let guidelineEntity = ModelEntity()
        
        // Create transparent guidelines for each part
        for part in availableParts {
            let size: SIMD3<Float>
            switch part.shape {
            case .box:
                size = [0.2, 0.2, 0.2]
            case .sphere:
                size = [0.2, 0.2, 0.2]
            case .tallBox:
                size = [0.1, 0.2, 0.1]
            case .flatBox:
                size = [0.2, 0.1, 0.1]
            }
            
            let guideMesh = MeshResource.generateBox(size: size)
            let material = SimpleMaterial(
                color: .white.withAlphaComponent(0.3),
                isMetallic: false
            )
            let boxEntity = ModelEntity(mesh: guideMesh, materials: [material])
            boxEntity.position = part.position
            guidelineEntity.addChild(boxEntity)
        }
        
        anchor.addChild(guidelineEntity)
        arView.scene.addAnchor(anchor)
        shipGuidelineAnchor = anchor
    }
    
    func selectPart(_ part: ShipPart) {
        selectedPartId = part.id
    }
    
    func handleTap(at transform: simd_float4x4) {
        guard let selectedId = selectedPartId,
              let part = availableParts.first(where: { $0.id == selectedId && !$0.isPlaced }),
              let anchor = shipGuidelineAnchor else { return }
        
        let entity = createPartEntity(for: part)
        entity.position = part.position
        anchor.addChild(entity)
        
        if let index = availableParts.firstIndex(where: { $0.id == selectedId }) {
            availableParts[index].isPlaced = true
        }
        
        placedParts += 1
        selectedPartId = nil
    }
    
    private func createPartEntity(for part: ShipPart) -> ModelEntity {
        let mesh: MeshResource
        let size: SIMD3<Float>
        
        switch part.shape {
        case .box:
            size = [0.2, 0.2, 0.2]
            mesh = .generateBox(size: size)
        case .sphere:
            mesh = .generateSphere(radius: 0.1)
        case .tallBox:
            size = [0.1, 0.2, 0.1]
            mesh = .generateBox(size: size)
        case .flatBox:
            size = [0.2, 0.1, 0.1]
            mesh = .generateBox(size: size)
        }
        
        let material = SimpleMaterial(color: part.color, isMetallic: true)
        return ModelEntity(mesh: mesh, materials: [material])
    }
    
    func resetGame() {
        guard let arView = arView else { return }
        
        // Reset AR scene
        arView.scene.anchors.removeAll()
        
        // Reset game state
        placedParts = 0
        selectedPartId = nil
        scanningFloor = true
        
        // Reset parts
        setupParts()
        
        // Reset AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
    }
}

// MARK: - Supporting Types and Views
struct ShipPart: Identifiable {
    let id: Int
    let name: String
    let shape: ShapeType
    let color: UIColor
    let position: SIMD3<Float>
    var isPlaced: Bool = false
    
    enum ShapeType {
        case box
        case sphere
        case flatBox
        case tallBox
    }
}

struct ScanningOverlayView: View {
    var body: some View {
        VStack {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.white)
            
            Text("Point your camera at a flat surface")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
        }
    }
}

struct ShipPartButton: View {
    let part: ShipPart
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(part.color))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: iconName(for: part.shape))
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                
                Text(part.name)
                    .foregroundColor(.white)
            }
        }
        .disabled(part.isPlaced)
        .opacity(part.isPlaced ? 0.5 : 1)
    }
    
    private func iconName(for shape: ShipPart.ShapeType) -> String {
        switch shape {
        case .box: return "square.fill"
        case .sphere: return "circle.fill"
        case .tallBox: return "rectangle.portrait.fill"
        case .flatBox: return "rectangle.fill"
        }
    }
}

struct EnhancedInstructionsView: View {
    let dismissAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
            
            VStack(spacing: 20) {
                Text("How to Build Your Ship")
                    .font(.title)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 15) {
                    InstructionRow(number: 1, text: "Point your camera at a flat surface")
                    InstructionRow(number: 2, text: "Wait for the ship outline to appear")
                    InstructionRow(number: 3, text: "Select a ship part from the bottom menu")
                    InstructionRow(number: 4, text: "Tap the outline where the part should go")
                    InstructionRow(number: 5, text: "Complete the ship by placing all parts")
                }
                .padding()
                
                Button("Start Building") {
                    dismissAction()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .foregroundColor(.white)
        }
    }
}

struct SuccessView: View {
    let dismissAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
            
            VStack(spacing: 20) {
                Text("Congratulations!")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("You've successfully built the ship!")
                    .foregroundColor(.white)
                
                Button("Play Again") {
                    dismissAction()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}
