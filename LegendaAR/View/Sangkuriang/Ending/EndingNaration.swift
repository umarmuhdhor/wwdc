import SwiftUI
import AVFoundation

struct EndingNaration: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @Binding var showEndingView: Bool
    @State private var showNarrationView = false
    @State private var z = false
    @State private var displayedText = ""
    let fullText = "Just before Sangkuriang could finish his boat, the first light of dawn broke across the sky. Realizing he had failed, his fury consumed him. In a fit of rage, he kicked the boat with all his might.The great vessel overturned, its massive form turning to stone—forever known as Mount Tangkuban Perahu. Overwhelmed by his anger and sorrow, Sangkuriang vanished without a trace, leaving behind a legend that would be told for generations."
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    CloseButton(isPresented: $showEndingView)
                        .onTapGesture {
                            audioManager.stopAudio()
                            showEndingView = false
                        }
                    Spacer()
                    
                    Text(displayedText)
                        .font(.system(size: 24))
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
                RewardsView()
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
            speed: 0.02
        ) {}
    }
}



// MARK: - Preview Providers
struct EndingNaration_Previews: PreviewProvider {
    static var previews: some View {
        OpeningView(showOpeningView: .constant(true))
    }
}

