import SwiftUI
import ARKit
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Konfigurasi ARKit
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        // Tambahkan Model 3D
        add3DModel(to: arView)
        
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    private func add3DModel(to arView: ARView) {
        do {
            let modelEntity = try ModelEntity.load(named: "Benang_3D")
            let anchorEntity = AnchorEntity(plane: .horizontal)
            anchorEntity.addChild(modelEntity)
            arView.scene.addAnchor(anchorEntity)
        } catch {
            print("❌ Gagal memuat model: \(error)")
        }
    }
}
