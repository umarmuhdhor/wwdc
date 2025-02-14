import SwiftUI
import AVKit

struct OpeningView: View {
    @State private var player: AVAudioPlayer?
    @State private var showNarrationView = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("This is the story behind Mount Tangkuban Perahu...")
                    .foregroundColor(.white)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .onAppear {
            playOpeningMusic()
        }
        .forceLandscape() // Memaksa landscape
        .fullScreenCover(isPresented: $showNarrationView) {
            Narration1View()
        }
    }

    private func playOpeningMusic() {
        if let url = Bundle.main.url(forResource: "DayangSumbi_1", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + (player?.duration ?? 5)) {
                    showNarrationView = true
                }
            } catch {
                print("Error loading audio: \(error.localizedDescription)")
            }
        }
    }
}
