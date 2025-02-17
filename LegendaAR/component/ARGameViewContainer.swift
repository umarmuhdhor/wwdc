import SwiftUI
import ARKit
import RealityKit

struct ARGameViewContainer: UIViewRepresentable {
    @Binding var showChoiceDialog: Bool
    @Binding var gameResult: GameResult?
    var audioManager: AudioPlayerManager
    
    func makeUIView(context: Context) -> ARView {
        // Create an AR view
        let arView = ARView(frame: .zero)
        
        // Configure the AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        // Create anchor for the scene
        let anchor = AnchorEntity(plane: .horizontal)
        arView.scene.addAnchor(anchor)
        
        // Load and add Tumang (dog) model
        loadTumangModel(anchor: anchor)
        
        // Start game sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            // Show Sangkuriang after 10 seconds
            self.showSangkuriang(arView, anchor: anchor)
        }
        
        // Add gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(ARGameCoordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // Store ARView reference
        context.coordinator.arView = arView
        context.coordinator.anchor = anchor
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update logic if needed
    }
    
    private func loadTumangModel(anchor: AnchorEntity) {
        // Load Tumang model
        if let tumangModel = try? ModelEntity.load(named: "3D_Sangkuriang") {
            // Scale and position the model
            tumangModel.scale = SIMD3<Float>(0.5, 0.5, 0.5)
            tumangModel.position = SIMD3<Float>(0, 0, -1.0)
            tumangModel.name = "mesh2"
            
            // Add model to anchor
            anchor.addChild(tumangModel)
            
            // Start dog walking animation - simplified movement
//            moveEntityInCircle(tumangModel)
        }
    }
    
    private func moveEntityInCircle(_ entity: ModelEntity) {
        let radius: Float = 2.0
        let duration: TimeInterval = 20.0
        
        // Manual animation setup using transforms
        func updatePosition(_ time: TimeInterval) {
            let angle = Float(time * 2 * Double.pi / duration)
            let x = radius * sin(angle)
            let z = radius * cos(angle)
            entity.position = SIMD3<Float>(x, 0, z)
            
            // Rotate the model to face the movement direction
            let rotationAngle = angle + .pi // Facing inward
            entity.orientation = simd_quatf(angle: rotationAngle, axis: SIMD3<Float>(0, 1, 0))
        }
        
        // Initial position
        updatePosition(0)
        
        // Create a timer to update position
        let timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            let time = Date().timeIntervalSince1970
            updatePosition(time)
        }
        
        // Keep timer referenced
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func showSangkuriang(_ arView: ARView, anchor: AnchorEntity) {
        // Create a 2D image for Sangkuriang
        let plane = ModelEntity(
            mesh: .generatePlane(width: 1, height: 2),
            materials: [SimpleMaterial(color: .white, isMetallic: false)]
        )
        
        // Load Sangkuriang image as texture
        if let texture = try? TextureResource.load(named: "Sangkuriang") {
            var material = SimpleMaterial()
            material.baseColor = MaterialColorParameter.texture(texture)
            material.tintColor = .white
            plane.model?.materials = [material]
        }
        
        // Position Sangkuriang to face the camera
        plane.position = SIMD3<Float>(0, 0.5, -2.0)
        plane.name = "sangkuriang"
        anchor.addChild(plane)
        
        // Play Sangkuriang's dialogue
        audioManager.playAudio(filename: "SangkuriangHunting")
        
        // Show dialogue text
        showDialogueText(anchor: anchor, text: "I couldn't find a deer... Maybe Tumang's heart will do?")
    }
    
    func showDialogueText(anchor: AnchorEntity, text: String) {
        // Create a background plane for the text
        let backgroundPlane = ModelEntity(
            mesh: .generatePlane(width: 1.5, height: 0.3),
            materials: [SimpleMaterial(color: UIColor.white.withAlphaComponent(0.7), isMetallic: false)]
        )
        
        backgroundPlane.position = SIMD3<Float>(0, 2.2, -2.0)
        
        // Add text as a separate entity
        let textEntity = ModelEntity()
        textEntity.position = SIMD3<Float>(0, 0, -0.01) // Slightly in front of background
        backgroundPlane.addChild(textEntity)
        
        // Create text mesh - simplified approach
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.1),
            alignment: .center
        )
        
        textEntity.model = ModelComponent(
            mesh: textMesh,
            materials: [SimpleMaterial(color: .black, isMetallic: false)]
        )
        
        // Adjust text position to be centered
        textEntity.position.y -= 0.04
        
        // Add to scene
        anchor.addChild(backgroundPlane)
        
        // Remove text after several seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            backgroundPlane.removeFromParent()
        }
    }
    
    // MARK: - Coordinator
    
    func makeCoordinator() -> ARGameCoordinator {
        ARGameCoordinator(
            showChoiceDialog: $showChoiceDialog,
            gameResult: $gameResult,
            audioManager: audioManager
        )
    }
}
