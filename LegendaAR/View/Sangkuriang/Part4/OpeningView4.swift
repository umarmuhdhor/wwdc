import SwiftUI
import AVFoundation

struct OpeningView4: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @Binding var showOpeningView: Bool
    @State private var showNarrationView = false
    @State private var z = false
    @State private var displayedText = ""
    let fullText = "Sangkuriang couldn't find the deer he was hunting for, so he decided to take Tumang's heart instead."
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    CloseButton(isPresented: $showOpeningView)
                        .onTapGesture {
                            audioManager.stopAudio()
                            showOpeningView = false
                        }
                    Spacer()
                    
                    Text(displayedText)
                        .foregroundColor(.white)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()
                        .onAppear {
                            startAnimation()
                        }
                    
                    Spacer()
                    Spacer()
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NextButton(title: "Skip") {
                            audioManager.stopAudio()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                z = true
                            }
                        }
                        .padding(.trailing, geo.size.width * 0.08)
                        .padding(.bottom, geo.size.height * 0.1)
                    }
                }
                
            }
            .onAppear {
                setupAndPlay()
            }
            .onDisappear {
                audioManager.stopAudio()
            }
            .forceLandscape()
            .fullScreenCover(isPresented: $z) {
                HuntingGameView(showGameView: $z)
            }
            .transaction { $0.disablesAnimations = true }
        }
        
    }
    
    private func setupAndPlay() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            
            audioManager.playAudio(filename: "Typing")
            let audioDuration = audioManager.audioPlayer?.duration ?? 5
            
            DispatchQueue.main.asyncAfter(deadline: .now() + audioDuration + 2) {
                showNarrationView = true
            }
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    private func startAnimation() {
        TextAnimation.animateText(
            text: fullText,
            displayedText: $displayedText,
            speed: 0.09
        ) {}
    }
}



// MARK: - Preview Providers
struct OpeningView4_Previews: PreviewProvider {
    static var previews: some View {
        OpeningView(showOpeningView: .constant(true))
    }
}

