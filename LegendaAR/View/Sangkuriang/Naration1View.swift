import SwiftUI
import AVFoundation

class AudioPlayerManager: ObservableObject {
    @Published var audioPlayer: AVAudioPlayer?
    
    func playAudio(filename: String) {
        if let path = Bundle.main.path(forResource: filename, ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            } catch {
                print("Error playing audio file: \(filename)")
            }
        }
    }
}

struct Narration1View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var isThreadFalling = false
    @State private var isDayangSumbiVisible = false
    @State private var isNextButtonVisible = false
    @State private var displayedText = ""
    @State private var wordIndex = 0
    @State private var isTextVisible = false

    let fullText = [
        "Long", "ago,", "in", "the", "lush", "lands", "of", "Sunda,",
        "there", "lived", "a", "beautiful", "princess", "named", "Dayang", "Sumbi.",
        "She", "was", "known", "for", "her", "unmatched", "beauty", "and", "extraordinary",
        "skill", "in", "weaving."
    ]

    var body: some View {
        ZStack {
            Image("background_narasi1")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            if isThreadFalling {
                Image("thread_spool")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .offset(y: isThreadFalling ? 400 : -200)
                    .animation(.easeIn(duration: 1.5), value: isThreadFalling)
                    .onAppear {
                        Task {
                            try await Task.sleep(nanoseconds: 2_500_000_000)
                            isDayangSumbiVisible = true
                            audioManager.playAudio(filename: "DayangSumbi_1")
                        }
                    }
            }

            if isDayangSumbiVisible {
                Image("DayangSumbi_2D")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400) // Diperbesar
                    .offset(x: 120, y: 100) // Pindahkan ke kanan bawah, tapi tidak terlalu pojok
                    .transition(.opacity)
                    .onAppear {
                        Task {
                            try await Task.sleep(nanoseconds: 2_000_000_000)
                            isNextButtonVisible = true
                        }
                    }
            }

            if isTextVisible {
                Text(displayedText)
                    .font(.body) // Ukuran teks lebih kecil
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(10)
                    .offset(y: 200) // Letakkan teks di bawah tengah
                    .onAppear {
                        showWordsGradually()
                    }
            }

            if isNextButtonVisible {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Text("Find the Thread")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 180)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            audioManager.playAudio(filename: "Narasi1_fix")
            Task {
                try await Task.sleep(nanoseconds: 15_000_000_000)
                isTextVisible = true
                try await Task.sleep(nanoseconds: UInt64((audioManager.audioPlayer?.duration ?? 5) * 1_000_000_000))
                isThreadFalling = true
                isTextVisible = false // Hapus teks setelah selesai
            }
        }
    }

    func showWordsGradually() {
        displayedText = ""
        wordIndex = 0

        for i in 0..<fullText.count {
            Task {
                try await Task.sleep(nanoseconds: UInt64(Double(i) * 0.5 * 1_000_000_000))
                displayedText += (i == 0 ? "" : " ") + fullText[i]
            }
        }
    }
}

struct Narration1View_Previews: PreviewProvider {
    static var previews: some View {
        Narration1View()
    }
}
