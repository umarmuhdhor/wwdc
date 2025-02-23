
import SwiftUI
import AVFoundation

struct EndingNaration: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @Binding var showEndingView: Bool
    @State private var showNarrationView = false
    @State private var z = false
    @State private var displayedText = ""
    @State private var isAnimationComplete = false
    @State private var showNextButton = false

    @State private var textAnimationTimer: Timer?
    
    let fullText = "Just before Sangkuriang could finish his boat, the first light of dawn broke across the sky. Realizing he had failed, his fury consumed him. In a fit of rage, he kicked the boat with all his might.The great vessel overturned, its massive form turning to stone—forever known as Mount Tangkuban Perahu. Overwhelmed by his anger and sorrow, Sangkuriang vanished without a trace, leaving behind a legend that would be told for generations."
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    CloseButton(isPresented: $showEndingView)
                        .onTapGesture {
                            textAnimationTimer?.invalidate()
                            audioManager.stopAudio()
                            showEndingView = false
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
                RewardsView(isPresented: $z)
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
            speed: 0.0235
        ) {
            showNextButton = true
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

struct EndingNaration_Previews: PreviewProvider {
    static var previews: some View {
        EndingNaration(showEndingView: .constant(true))
    }
}








