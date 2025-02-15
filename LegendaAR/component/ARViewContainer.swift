import SwiftUI
import ARKit
import RealityKit
import Combine

class TreasureHuntState: ObservableObject {
    @Published var foundCount: Int = 0
    let totalCount: Int = 3
}

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var state: TreasureHuntState
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.translatesAutoresizingMaskIntoConstraints = false
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                               action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        
        // Setup initial models
        setupInitialModels(in: arView)
        
       
        
        return arView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    private func setupInitialModels(in arView: ARView) {
        let positions: [SIMD3<Float>] = [
            SIMD3<Float>(-0.9, 0.1, -0.005),
            SIMD3<Float>(0.0, 0.05, -0.3),
            SIMD3<Float>(0.4, 0.05, -0.5)
        ]
        
        for position in positions {
            placeHiddenModel(at: position, in: arView)
        }
    }
    
    private func placeHiddenModel(at position: SIMD3<Float>, in arView: ARView) {
        do {
            let anchorEntity = AnchorEntity(plane: .horizontal)
            let modelEntity = try ModelEntity.load(named: "Benang_3D")
            
            let scale: Float = 0.12
            modelEntity.scale = SIMD3<Float>(scale, scale, scale)
            modelEntity.position = position
            
            // Hide model initially
            modelEntity.isEnabled = true
            
            // Add collision component for tap detection
            modelEntity.generateCollisionShapes(recursive: true)
            modelEntity.name = "hiddenBenang" // Pastikan nama ini konsisten
            
            anchorEntity.addChild(modelEntity)
            arView.scene.addAnchor(anchorEntity)
            
            // Debug: Log posisi benang
            print("📍 Benang ditempatkan di posisi: \(position)")
            print("🟢 AnchorEntity ditambahkan ke scene")
            print("🟢 ModelEntity ditambahkan ke AnchorEntity")
            
        } catch {
            print("❌ Gagal memuat model 3D: \(error)")
        }
    }
    
    class Coordinator: NSObject {
        var parent: ARViewContainer
        
        init(parent: ARViewContainer) {
            self.parent = parent
        }
        
        
        
        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = recognizer.view as? ARView else {
                print("❌ Tidak bisa mendapatkan ARView dari gesture recognizer")
                return
            }
            
            let tapLocation = recognizer.location(in: arView)
            
            if let entity = arView.entity(at: tapLocation) {
                let modelEntity = entity as? ModelEntity ?? entity.children.compactMap { $0 as? ModelEntity }.first
                
                guard let foundEntity = modelEntity else {
                    print("❌ Tidak ada ModelEntity yang valid dalam entity yang diklik")
                    return
                }

                print("🖐️ Tap terdeteksi pada entitas: \(foundEntity.name)")

                if foundEntity.name == "hiddenBenang" {
                    foundEntity.isEnabled = false // Sembunyikan setelah ditemukan
                    parent.state.foundCount += 1
                    print("🎉 Benang ditemukan! Total ditemukan: \(parent.state.foundCount)")
                }
            }

        }

    }
}
