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

// MARK: - Ship Part Definition
struct ShipPart: Identifiable {
    let id: Int
    let name: String
    let modelName: String  // Name of the USDZ file
    let position: SIMD3<Float>
    let rotation: simd_quatf
    let previewImageName: String // Name of the preview image for the button
    var isPlaced: Bool = false
}

// MARK: - AR View Model
class ARViewModel: ObservableObject {
    @Published var placedParts = 0
    @Published var selectedPartId: Int?
    @Published var scanningFloor = true
    @Published var availableParts: [ShipPart] = []
    
    let totalParts = 6
    weak var arView: ARView?
    private var shipGuidelineAnchor: AnchorEntity?
    private var shipGuidelineEntity: ModelEntity?
    
    init() {
        setupParts()
    }
    
    private func setupParts() {
        // Define the parts with their positions and rotations
        //diperbesar kearah lower
        availableParts = [
            ShipPart(id: 1,
                     name: "Front Upper",
                     modelName: "FrUp",
                     position: SIMD3<Float>(0, 0.05, 0.35),
                     rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
                     previewImageName: "front_upper_preview"),
            
            ShipPart(id: 2,
                     name: "Front Lower",
                     modelName: "FrLow",
                     position: SIMD3<Float>(0, 0, 0.35),
                     rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
                     previewImageName: "front_lower_preview"),
            
            ShipPart(id: 3,
                     name: "Middle Upper",
                     modelName: "MdUp",
                     position: SIMD3<Float>(0, 0.07, 0.35),
                     rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
                     previewImageName: "middle_upper_preview"),
            
            ShipPart(id: 4,
                     name: "Middle Lower",
                     modelName: "MdLow",
                     position: SIMD3<Float>(0, 0, 0.35),
                     rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
                     previewImageName: "middle_lower_preview"),
            
            ShipPart(id: 5,
                     name: "Back Upper",
                     modelName: "BkUp",
                     position: SIMD3<Float>(0, 0.05, 0.4),
                     rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
                     previewImageName: "back_upper_preview"),
            
            ShipPart(id: 6,
                     name: "Back Lower",
                     modelName: "BkLow",
                     position: SIMD3<Float>(0, 0.03, 0.4),
                     rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
                     previewImageName: "back_lower_preview")
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
        
        // Create new anchor
        let anchor = AnchorEntity(world: transform)
        
        // Load the ship guideline model
        do {
            let shipModel = try ModelEntity.loadModel(named: "ship")
            shipModel.scale = [1, 1, 1] // Adjust scale as needed
            shipModel.position = [0, 0, 0] // Adjust position as needed
                    
            // Make the model semi-transparent
            var material = SimpleMaterial()
            material.baseColor = .init(_colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
            material.roughness = .init(floatLiteral: 0.8)
            material.metallic = .init(floatLiteral: 0.0)
            shipModel.model?.materials = [material]
                    
            anchor.addChild(shipModel)
            shipGuidelineEntity = shipModel
        } catch {
            print("Failed to load ship model: \(error)")
        }
        
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
        
        // Load and place the selected part
        do {
            let entity = try ModelEntity.load(named: part.modelName)
            entity.position = part.position
            entity.orientation = part.rotation
            
            anchor.addChild(entity)
            
            if let index = availableParts.firstIndex(where: { $0.id == selectedId }) {
                availableParts[index].isPlaced = true
            }
            
            placedParts += 1
            selectedPartId = nil
            
        } catch {
            print("Failed to load part model: \(error)")
        }
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

// MARK: - Supporting Views
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
                Image(part.previewImageName)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                
                Text(part.name)
                    .foregroundColor(.white)
            }
        }
        .disabled(part.isPlaced)
        .opacity(part.isPlaced ? 0.5 : 1)
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
