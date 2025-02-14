import SwiftUI

struct ForceLandscapeViewModifier: ViewModifier {
    init() {
        forceLandscape()
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                forceLandscape()
            }
    }
    
    private func forceLandscape() {
        DispatchQueue.main.async {
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
}

extension View {
    func forceLandscape() -> some View {
        self.modifier(ForceLandscapeViewModifier())
    }
}
