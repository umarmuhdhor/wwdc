import SwiftUI
import AVFoundation

struct OpeningView6: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @Binding var showOpeningView: Bool
    @State private var showNarrationView = false
    @State private var z = false
    @State private var displayedText = ""
    @State private var isAnimationComplete = false
    @State private var showNextButton = false
    
    @State private var textAnimationTimer: Timer?
    
    let fullText = "In her anger, Dayang Sumbi struck Sangkuriang's head so hard that it bled, and then she banished him from the house."
    
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
                Narration6View(showNarrationView: $z)
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + audioDuration) {
                showNextButton = true
            }
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    private func startAnimation() {
        textAnimationTimer = TextAnimation.animateText(
            text: fullText,
            displayedText: $displayedText,
            speed: 0.07
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

struct OpeningView6_Previews: PreviewProvider {
    static var previews: some View {
        OpeningView6(showOpeningView: .constant(true))
    }
}






