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

    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

struct Narration1View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var threadPositiony : CGFloat = -50  // Mulai dari tengah atas
    @State private var threadPositionx : CGFloat = 100  // Mulai dari tengah atas
    @State private var isThreadAnimating = false  // Untuk animasi rotasi
    @State private var isDayangSumbiVisible = false
    @State private var isNextButtonVisible = false
    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var isTextVisible = false
    @State private var navigateToARView = false
    @Binding var showNarrationView: Bool

    let fullText = "Long ago, in the lush lands of Sunda, there lived a beautiful princess named Dayang Sumbi. She was known for her unmatched beauty and extraordinary skill in weaving."

    var minimalistButton: some View {
        Button(action: {
            audioManager.stopAudio()
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

                VStack {
                    CloseButton(isPresented: $showNarrationView)
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            audioManager.stopAudio()
                            showNarrationView = false
                        }
                    Spacer()
                }

                // Benang jatuh dari tengah ke bawah
                Image("thread_spool")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .offset(x : threadPositionx,y: threadPositiony)
                    .opacity(threadPositiony == -50 ? 0 : 1) // Tampil setelah bergerak
                    .animation(.easeInOut(duration: 3.0), value: threadPositiony)

                if isDayangSumbiVisible {
                    Image("DayangSumbi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                        .offset(x: 150, y: 100)
                        .transition(.opacity)
                        .onAppear {
                            audioManager.playAudio(filename: "DayangSumbi_1")
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
                            startTextAnimation()
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
                audioManager.playAudio(filename: "Narasi1")
                let narrationDuration = audioManager.audioPlayer?.duration ?? 5

                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    isTextVisible = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + narrationDuration - 5) {
                        isTextVisible = false
                        
                        // Mulai animasi benang jatuh dari tengah
                        withAnimation(.easeInOut(duration: 2.0)) {
                            threadPositiony = 180  // Jatuh ke bawah
                            threadPositionx = -300
                        }

                        // Putar benang saat jatuh
                        withAnimation(.linear(duration: 3.0)) {
                            isThreadAnimating = true
                        }

                        // Setelah benang jatuh, tampilkan Dayang Sumbi
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            isDayangSumbiVisible = true
                        }
                    }
                }
            }
            .onDisappear {
                audioManager.stopAudio()
            }
            .forceLandscape()
        }
    }

    private func startTextAnimation() {
        displayedText = ""
        currentIndex = 0

        Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { timer in
            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                displayedText.append(fullText[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

struct Narration1View_Previews: PreviewProvider {
    static var previews: some View {
        Narration1View(showNarrationView: .constant(true))
    }
}
