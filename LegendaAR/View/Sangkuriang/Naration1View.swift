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
                    .offset(y: isThreadFalling ? 180 : 0)
                    .animation(.easeOut(duration: 3.0), value: isThreadFalling)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isThreadFalling = true
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            isDayangSumbiVisible = true
                            audioManager.playAudio(filename: "DayangSumbi_1")
                        }
                    }
            }

            if isDayangSumbiVisible {
                Image("DayangSumbi_2D")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400)
                    .offset(x: 150, y: 100)
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isNextButtonVisible = true
                        }
                    }
            }

            if isTextVisible {
                Text(displayedText)
                    .font(.body)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(10)
                    .offset(y: 180)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                isTextVisible = true
                DispatchQueue.main.asyncAfter(deadline: .now() + (audioManager.audioPlayer?.duration ?? 5)) {
                    isThreadFalling = true
                    isTextVisible = false // Hapus teks setelah selesai
                }
            }
        }
    }

    func showWordsGradually() {
        displayedText = ""
        wordIndex = 0

        for i in 0..<fullText.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
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
