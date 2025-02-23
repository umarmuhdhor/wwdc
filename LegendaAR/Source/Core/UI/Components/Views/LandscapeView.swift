import SwiftUI

struct LandscapeModifier: ViewModifier {
    let orientationManager = OrientationManager.shared
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                orientationManager.lockOrientation(.landscape, andRotateTo: .landscapeRight)
            }
            .onDisappear {
                orientationManager.lockOrientation(.all)
            }
    }
}

extension View {
    func forceLandscape() -> some View {
        modifier(LandscapeModifier())
    }
}
