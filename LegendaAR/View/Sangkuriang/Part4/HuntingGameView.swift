import SwiftUI
import SpriteKit
import GameplayKit


struct HuntingGameView: View {
    @Binding var showGameView: Bool
    @State private var isNextButtonVisible = false
    @State private var navigateNextView = false
    
    var scene: SKScene {
        let scene = HuntingGameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        return scene
    }
    
    var body: some View {
        GeometryReader { geo in
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
                if isNextButtonVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NextButton(title: "Next") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    navigateNextView = true
                                }
                            }
                            .padding(.trailing, geo.size.width * 0.08)
                            .padding(.bottom, geo.size.height * 0.1)
                        }
                    }
                }
                
            }
        }
        .fullScreenCover(isPresented: $navigateNextView) {
            Narration5View(showNarrationView: $navigateNextView)
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("GameCompleted"),
            object: nil,
            queue: .main
        ) { _ in
            isNextButtonVisible = true
        }
    }
}
