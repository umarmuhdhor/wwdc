import SwiftUI
import AVFoundation

struct OpeningView: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @Binding var showOpeningView: Bool
    @State private var showNarrationView = false
    @State private var displayedText = ""
    let fullText = "In the misty highlands of West Java, a mountain stands as a silent witness to a tale of love, betrayal....."

    var body: some View {
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
        }
        .onAppear {
            setupAndPlay()
        }
        .onDisappear {
            audioManager.stopAudio()
        }
        .forceLandscape()
        .fullScreenCover(isPresented: $showNarrationView) {
            Narration1View(showNarrationView: $showNarrationView)
        }
    }
    
    private func setupAndPlay() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            
            audioManager.playAudio(filename: "Ketikan")
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
struct OpeningView_Previews: PreviewProvider {
    static var previews: some View {
        OpeningView(showOpeningView: .constant(true))
    }
}

