import SwiftUI
import AVFoundation

struct OpeningView: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @Binding var showOpeningView: Bool
    @State private var showNarrationView = false
    @State private var z = false
    @State private var displayedText = ""
    @State private var isAnimationComplete = false
    @State private var showNextButton = false
    
    @State private var textAnimationTimer: Timer?
    
    let fullText = "In the misty highlands of West Java, a mountain stands as a silent witness to a tale of love, betrayal."
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    CloseButton(isPresented: $showOpeningView)
                        .onTapGesture {
                            textAnimationTimer?.invalidate()
                            audioManager.stopAudio()
                            showOpeningView = false
                        }
                        .padding(.top, geo.size.height * 0.02)
                        .padding(.horizontal, geo.size.width * 0.05)
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
                        
                        if !showNextButton {
                            NextButton(title: "Skip Narration") {
                                skipNarration()
                            }
                            .padding(.trailing, 20)
                        }
                        
                        if showNextButton {
                            NextButton(title: "Next") {
                                textAnimationTimer?.invalidate()
                                audioManager.stopAudio()
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    z = true
                                }
                            }
                        }
                    }
                    .padding(.trailing, geo.size.width * 0.08)
                    .padding(.bottom, geo.size.height * 0.1)
                }
            }
            .onAppear {
                setupAndPlay()
            }
            .onDisappear {
                textAnimationTimer?.invalidate()
                audioManager.stopAudio()
            }
            .forceLandscape()
            .fullScreenCover(isPresented: $z) {
                Narration1View(showNarrationView: $z)
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
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    private func startAnimation() {
        textAnimationTimer = TextAnimation.animateText(
            text: fullText,
            displayedText: $displayedText,
            speed: 0.09
        ) {
            showNextButton = true
            audioManager.stopAudio() 
        }
    }
    
    private func skipNarration() {
        textAnimationTimer?.invalidate()
        textAnimationTimer = nil
        audioManager.stopAudio()
        displayedText = fullText
        showNextButton = true
    }
}
