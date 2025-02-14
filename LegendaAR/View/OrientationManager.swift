import SwiftUI

class OrientationManager: ObservableObject {
    static let shared = OrientationManager()
    
    @Published var currentOrientation: UIInterfaceOrientationMask = .all
    
    func lockOrientation(_ mask: UIInterfaceOrientationMask, andRotateTo orientation: UIInterfaceOrientation? = nil) {
        currentOrientation = mask
        AppDelegate.orientationLock = mask
        
        if let orientation = orientation {
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }
}
