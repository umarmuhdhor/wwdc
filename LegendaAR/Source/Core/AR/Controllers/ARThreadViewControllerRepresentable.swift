import SwiftUI
import ARKit
import RealityKit
import Combine

struct ARThreadViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var state: TreasureHuntState
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let arView = ARThreadViewContainer(state: state)
        let hostingController = UIHostingController(rootView: arView)
        
        viewController.addChild(hostingController)
        viewController.view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: viewController)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
