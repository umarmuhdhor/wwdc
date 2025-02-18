import SwiftUI
import SpriteKit
import GameplayKit


struct HuntingGameView: View {
    @Binding var showGameView: Bool
    @State private var navigateToNarration4 = false
    
    var scene: SKScene {
        let scene = HuntingGameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        return scene
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    setupNotificationObserver()
                }
            
            VStack {
                HStack {
                    Spacer()
                    CloseButton(isPresented: $showGameView)
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $navigateToNarration4) {
            Narration6View(showNarrationView: $navigateToNarration4)
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("GameCompleted"),
            object: nil,
            queue: .main
        ) { _ in
            navigateToNarration4 = true
        }
    }
}
