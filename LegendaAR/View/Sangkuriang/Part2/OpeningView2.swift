import SwiftUI
import AVFoundation

struct OpeningView2: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @Binding var showOpeningView: Bool
    @State private var showNarrationView = false
    @State private var z = false
    @State private var displayedText = ""
    @State private var isAnimationComplete = false
    @State private var showNextButton = false
    
    // Add state variable to store the animation timer
    @State private var textAnimationTimer: Timer?
    
    let fullText = "Dayang Sumbi keeps her promise and marries Tumang. Time passes, and she becomes pregnant. Her father, Sang Prabu, summons her to the palace."
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    CloseButton(isPresented: $showOpeningView)
                        .onTapGesture {
                            textAnimationTimer?.invalidate() // Invalidate timer when closing
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
                                textAnimationTimer?.invalidate() // Invalidate timer when moving to next screen
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
                textAnimationTimer?.invalidate() // Invalidate timer when view disappears
                audioManager.stopAudio()
            }
            .forceLandscape()
            .fullScreenCover(isPresented: $z) {
                Narration2View(showNarrationView: $z)
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
        // Store the timer reference
        textAnimationTimer = TextAnimation.animateText(
            text: fullText,
            displayedText: $displayedText,
            speed: 0.07
        ) {
            showNextButton = true
        }
    }
    
    private func skipNarration() {
        // Invalidate the timer to stop the animation
        textAnimationTimer?.invalidate()
        textAnimationTimer = nil
        
        // Stop audio
        audioManager.stopAudio()
        
        // Show full text immediately
        displayedText = fullText
        
        // Show next button
        showNextButton = true
    }
}

struct OpeningView2_Previews: PreviewProvider {
    static var previews: some View {
        OpeningView2(showOpeningView: .constant(true))
    }
}





