import SwiftUI
import AVFoundation

struct Narration1View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var coverScaleX: CGFloat = 1.0  // Tirai awalnya penuh
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
    @StateObject private var treasureState = TreasureHuntState()

    let fullText = "Long ago, in the lush lands of Sunda, there lived a beautiful princess named Dayang Sumbi. She was known for her unmatched beauty and extraordinary skill in weaving."

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    
                    Image("background_narasi1")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    
                    // Layer untuk efek layar terbuka dari tengah
                    HStack {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: geo.size.width / 2)
                            .offset(x: coverScaleX == 1.0 ? 0 : -geo.size.width / 2)
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: geo.size.width / 2)
                            .offset(x: coverScaleX == 1.0 ? 0 : geo.size.width / 2)
                    }
                    .animation(.easeOut(duration: 6.0), value: coverScaleX)
                    .onAppear {
                        withAnimation(.easeOut(duration: 6.0)) {
                            coverScaleX = 0.0  // Menutup layar seperti tirai dari tengah ke samping
                        }
                    }

                    VStack {
                        CloseButton(isPresented: $showNarrationView)
                            .padding(.top, geo.size.height * 0.02)
                            .padding(.trailing, geo.size.width * 0.05)
                            .onTapGesture {
                                audioManager.stopAudio()
                                showNarrationView = false
                            }
                        Spacer()
                    }

                    // Benang jatuh (Responsive)
                    Image("thread_spool")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.2) // Ukuran 20% dari lebar layar
                        .offset(
                            x: threadPositionx * geo.size.width / 390, // Sesuaikan dengan lebar layar
                            y: threadPositiony * geo.size.height / 844 // Sesuaikan dengan tinggi layar
                        )
                        .opacity(threadPositiony == -50 ? 0 : 1)
                        .animation(.easeInOut(duration: 3.0), value: threadPositiony)

                    // Dayang Sumbi (Responsive)
                    if isDayangSumbiVisible {
                        Image("DayangSumbi")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.5) // 50% dari lebar layar
                            .offset(x: geo.size.width * 0.2, y: geo.size.height * 0.2)
                            .transition(.opacity)
                            .onAppear {
                                audioManager.playAudio(filename: "DayangSumbi_1")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isNextButtonVisible = true
                                }
                            }
                    }

                    // Teks Narasi (Responsive)
                    if isTextVisible {
                        Text(displayedText)
                            .font(.body)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(width: geo.size.width * 0.95) // 80% dari lebar layar
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(10)
                            .offset(y: geo.size.height * 0.35) // Sesuaikan dengan tinggi layar
                            .onAppear {
                                startTextAnimation()
                            }
                    }

                    // Tombol Next (Responsive)
                    if isNextButtonVisible {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                NextButton(title: "Find the thread") {
                                    audioManager.stopAudio()
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        navigateToARView = true
                                    }
                                }
                                .padding(.trailing, geo.size.width * 0.08)
                                .padding(.bottom, geo.size.height * 0.1)
                            }
                        }
                    }

                    NavigationLink(
                        destination: ARGameView(state: treasureState)
                            .edgesIgnoringSafeArea(.all),
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

                            // Benang jatuh lebih adaptif
                            withAnimation(.easeInOut(duration: 1.0)) {
                                threadPositiony = geo.size.height * 0.75  // 20% dari tinggi layar
                                threadPositionx = geo.size.width * -0.25  // 30% ke kiri
                            }

                            // Putar benang saat jatuh
                            withAnimation(.linear(duration: 3.0)) {
                                isThreadAnimating = true
                            }

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
