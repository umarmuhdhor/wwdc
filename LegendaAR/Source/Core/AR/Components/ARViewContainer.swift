import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arViewModel.arView = arView
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.delegate = context.coordinator
        arView.session.run(config)
        
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
