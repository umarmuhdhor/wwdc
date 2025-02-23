import SwiftUI
import ARKit
import RealityKit
import Combine

class TreasureHuntState: ObservableObject {
    @Published var foundCount: Int = 0
    @Published var scale: Float = 0.07
    let totalCount: Int = 3
    static var cachedModel: ModelEntity?
    
    static func loadModel() -> ModelEntity? {
        do {
            let model = try ModelEntity.loadModel(named: "Benang_3D")
            let scale: Float = 0.07
            model.scale = SIMD3<Float>(scale, scale, scale)
            model.generateCollisionShapes(recursive: true)
            model.name = "mesh1"
            return model
        } catch {
            print("Failed to load model: \(error.localizedDescription)")
            return nil
        }
    }
}
struct ARThreadViewContainer: UIViewRepresentable {
    @ObservedObject var state: TreasureHuntState
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
            arView.session.pause()
        }
        
        DispatchQueue.main.async {
            context.coordinator.spawnNextThread(in: arView)
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let currentThread = context.coordinator.currentThread {
            currentThread.scale = SIMD3<Float>(state.scale, state.scale, state.scale)
        }
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARThreadViewContainer
        var currentThread: ModelEntity?
        
        init(parent: ARThreadViewContainer) {
            self.parent = parent
            super.init()
        }
        
        func spawnNextThread(in arView: ARView) {
            guard parent.state.foundCount < parent.state.totalCount else {
                print("All threads found!")
                return
            }
            
            if TreasureHuntState.cachedModel == nil {
                TreasureHuntState.cachedModel = TreasureHuntState.loadModel()
            }
            
            guard let model = TreasureHuntState.cachedModel?.clone(recursive: true) else {
                print("Failed to clone model")
                return
            }
            
            let randomPosition = SIMD3<Float>(
                Float.random(in: -0.5...0.5),
                Float.random(in: 0...0.2),
                Float.random(in: -0.5...0.5)
            )
            model.position = randomPosition
            model.isEnabled = true
            model.scale = SIMD3<Float>(parent.state.scale, parent.state.scale, parent.state.scale) 
            
            let anchorEntity = AnchorEntity(world: randomPosition)
            anchorEntity.addChild(model)
            arView.scene.addAnchor(anchorEntity)
            
            currentThread = model
            print("Thread spawned at position: \(randomPosition)")
        }
        
        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = recognizer.view as? ARView,
                  let currentThread = currentThread else { return }
            
            let location = recognizer.location(in: arView)
            
            if let entity = arView.entity(at: location), entity == currentThread {
                entity.removeFromParent()
                parent.state.foundCount += 1
                print("Thread found! Moving to the next one...")
                
                spawnNextThread(in: arView)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
