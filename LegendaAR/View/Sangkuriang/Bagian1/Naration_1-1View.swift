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
    @State private var navigateToARView = false
    
    let fullText = [
        "Long", "ago,", "in", "the", "lush", "lands", "of", "Sunda,",
        "there", "lived", "a", "beautiful", "princess", "named", "Dayang", "Sumbi.",
        "She", "was", "known", "for", "her", "unmatched", "beauty", "and", "extraordinary",
        "skill", "in", "weaving."
    ]
    
    var minimalistButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                navigateToARView = true
            }
        }) {
            HStack(spacing: 8) {
                Text("Find the Thread")
                    .font(.system(size: 16, weight: .medium))
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .transition(.opacity)
    }

    var body: some View {
        NavigationView {
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
                        .offset(y: 130)
                        .onAppear {
                            showWordsGradually()
                        }
                }

                if isNextButtonVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            minimalistButton
                                .padding(.trailing, 30)
                                .padding(.bottom, 30)
                        }
                    }
                }

                NavigationLink(
                    destination: ARViewContainer(),
                    isActive: $navigateToARView,
                    label: { EmptyView() }
                )
            }
            .onAppear {
                audioManager.playAudio(filename: "Narasi1_fix")
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    isTextVisible = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + (audioManager.audioPlayer?.duration ?? 5)) {
                        isThreadFalling = true
                        isTextVisible = false
                    }
                }
            }
            .forceLandscape()
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
