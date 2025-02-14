import SwiftUI
import ARKit
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: UIScreen.main.bounds) // Full-screen AR view

        // Configure ARKit session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal] // Detect only horizontal surfaces
        arView.session.run(config)

        // Delay before placing models (simulate user scanning the room)
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 5...6)) {
            self.add3DModels(to: arView)
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    private func add3DModels(to arView: ARView) {
        do {
            let anchorEntity = AnchorEntity(plane: .horizontal) // Attach models to detected surface
            
            // Generate random positions within a range
            let positions: [SIMD3<Float>] = (1...3).map { _ in
                SIMD3<Float>(
                    Float.random(in: -0.6...0.6),  // X-axis: spread out left & right
                    0.05,                         // Y-axis: stay above surface
                    Float.random(in: -0.6...0.6)   // Z-axis: spread out front & back
                )
            }

            for position in positions {
                let modelEntity = try ModelEntity.load(named: "Benang_3D")

                // Random scale to vary size a bit
                let randomScale: Float = Float.random(in: 0.18...0.25)
                modelEntity.scale = SIMD3<Float>(randomScale, randomScale, randomScale)

                // Set position
                modelEntity.position = position

                anchorEntity.addChild(modelEntity)
            }

            arView.scene.addAnchor(anchorEntity)
        } catch {
            print("❌ Failed to load 3D model: \(error)")
        }
    }
}
