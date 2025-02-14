import SwiftUI
import AVFoundation

struct OpeningView: View {
    @State private var player: AVAudioPlayer?
    @Binding var showOpeningView: Bool
    @State private var showNarrationView = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                CloseButton(isPresented: $showOpeningView)
                Spacer()

                Text("This is the story behind Mount Tangkuban Perahu...")
                    .foregroundColor(.white)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()

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
            Narration1View()
        }
    }

    // 🔹 Memastikan audio tetap berjalan di iPhone asli
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
        guard let url = Bundle.main.url(forResource: "DayangSumbi_1", withExtension: "mp3") else {
            print("Audio file not found!")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()

            // 🔹 Setelah audio selesai, buka Narration1View
            DispatchQueue.main.asyncAfter(deadline: .now() + (player?.duration ?? 5)) {
                showNarrationView = true
            }
        } catch {
            print("Error loading audio: \(error.localizedDescription)")
        }
    }
}
