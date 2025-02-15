import SwiftUI
import AVFoundation

struct OpeningView: View {
    @State private var player: AVAudioPlayer?
    @Binding var showOpeningView: Bool
    @State private var showNarrationView = false
    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    let fullText: String = "In the misty highlands of West Java, a mountain stands as a silent witness to a tale of love, betrayal."

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                CloseButton(isPresented: $showOpeningView)
                Spacer()

                Text(displayedText)
                    .foregroundColor(.white)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                    .onAppear {
                        startTextAnimation()
                    }

                Spacer()
            }
        }
        .onAppear {
            setupAudioSession()
            playOpeningMusic()
        }
        .onDisappear {
            player?.stop()
        }
        .forceLandscape()
        .fullScreenCover(isPresented: $showNarrationView) {
            Narration1View(showNarrationView: $showNarrationView)
        }
    }

    private func startTextAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.09, repeats: true) { timer in
            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                displayedText.append(fullText[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    private func playOpeningMusic() {
        guard let url = Bundle.main.url(forResource: "Ketikan", withExtension: "mp3") else {
            print("Audio file not found!")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()

            // Tambahkan jeda 2 detik setelah audio selesai
            let audioDuration = player?.duration ?? 5
            DispatchQueue.main.asyncAfter(deadline: .now() + audioDuration + 2) {
                showNarrationView = true
            }
        } catch {
            print("Error loading audio: \(error.localizedDescription)")
        }
    }
}
