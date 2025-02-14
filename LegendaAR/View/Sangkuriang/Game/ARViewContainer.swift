import SwiftUI
import ARKit
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure ARKit
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        // Improve environment realism
        arView.environment.sceneUnderstanding.options.insert(.occlusion)
        arView.automaticallyConfigureSession = true
        
        // Add 3D Model
        add3DModel(to: arView)
        
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    private func add3DModel(to arView: ARView) {
        do {
            let modelEntity = try ModelEntity.load(named: "Thread_Spool_3D")
            
            // Scale the model to a reasonable size
            modelEntity.scale = SIMD3<Float>(0.2, 0.2, 0.2)
            
            // Add physics for realism
            modelEntity.generateCollisionShapes(recursive: true)
            modelEntity.physicsBody = PhysicsBodyComponent(
                massProperties: .default,
                material: nil,
                mode: .dynamic
            )
            
            // Add floating animation
            let floatUp = Transform(scale: modelEntity.scale, rotation: modelEntity.transform.rotation, translation: [0, 0.02, 0])
            let floatDown = Transform(scale: modelEntity.scale, rotation: modelEntity.transform.rotation, translation: [0, -0.02, 0])
            let animation = modelEntity.move(to: floatUp, relativeTo: modelEntity, duration: 1.5, timingFunction: .easeInOut)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                modelEntity.move(to: floatDown, relativeTo: modelEntity, duration: 1.5, timingFunction: .easeInOut)
            }
            
            // Create anchor
            let anchorEntity = AnchorEntity(plane: .horizontal)
            anchorEntity.addChild(modelEntity)
            arView.scene.addAnchor(anchorEntity)
        } catch {
            print("❌ Failed to load model: \(error)")
        }
    }
}
