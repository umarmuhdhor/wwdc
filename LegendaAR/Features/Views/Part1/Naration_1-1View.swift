    import SwiftUI
    import AVFoundation

    struct Narration1View: View {
        @StateObject private var audioManager = AudioPlayerManager()
        @State private var coverScaleX: CGFloat = 1.0
        @State private var threadPositiony: CGFloat = -50
        @State private var threadPositionx: CGFloat = 100
        @State private var isThreadAnimating = false
        @State private var isDayangSumbiVisible = false
        @State private var isNextButtonVisible = false
        @State private var showGameView = true
        @State private var displayedText = ""
        @State private var currentIndex = 0
        @State private var isTextVisible = false
        @State private var isDayangDialogueVisible = false
        @State private var navigateToARView = false
        @State private var isSkipVisible = false
        @Binding var showNarrationView: Bool
        @State private var curtainOffset: CGFloat = 0
        @State private var isCurtainOpen = false
        @StateObject private var treasureState = TreasureHuntState()
        
        @State private var textAnimationTimer: Timer?
        
        let fullText = "Long ago, in the lush lands of Sunda, there lived a beautiful princess named Dayang Sumbi. She was known for her unmatched beauty and extraordinary skill in weaving."
        let dayangDialogue = "Oh no! My thread has fallen into the bushes! If someone retrieves it for me, if it's a woman, I will make her my lifelong sister, and if it's a man, I will marry him."
        
        var body: some View {
                GeometryReader { geo in
                    ZStack {
                        Image("background_narasi1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                            .edgesIgnoringSafeArea(.all)
                        
                        HStack(spacing: 0) {
                            CurtainView(side: .left, offset: curtainOffset)
                            CurtainView(side: .right, offset: curtainOffset)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2.0)) {
                                curtainOffset = geo.size.width
                                isCurtainOpen = true
                            }
                        }
                        
                        // Close button & Skip button in a single HStack
                        VStack {
                            HStack {
                                if isSkipVisible {
                                    NextButton(title: "Skip Narration") {
                                        audioManager.stopAudio()
                                        
                                        // Hentikan animasi teks
                                        textAnimationTimer?.invalidate()
                                        textAnimationTimer = nil
                                        
                                        // Kosongkan atau hentikan pembaruan teks
                                        displayedText = "" // Kosongkan teks yang ditampilkan
                                        isTextVisible = false // Sembunyikan teks
                                        isSkipVisible = false // Sembunyikan tombol skip
                                        
                                        // Lanjutkan ke bagian berikutnya
                                        withAnimation(.linear(duration: 1.0)) {
                                            isThreadAnimating = true
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                            isDayangSumbiVisible = true
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                CloseButton(isPresented: $showNarrationView)
                                    .onTapGesture {
                                        audioManager.stopAudio()
                                        showNarrationView = false
                                    }
                            }
                            .padding(.top, geo.size.height * 0.02)
                            .padding(.horizontal, geo.size.width * 0.05) // Mengatur posisi horizontal
                            Spacer()
                        }
                        
                        
                        // Thread
                        Image("thread_spool")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.2) // 20% dari lebar layar
                            .offset(
                                x: geo.size.width * -0.2, // Posisi berdasarkan layar
                                y: geo.size.height * 0.3
                            )
                        
                        // Dayang Sumbi
                        if isDayangSumbiVisible {
                            Image("DayangSumbi")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.3) // 50% dari lebar layar
                                .offset(x: geo.size.width * 0.2, y: geo.size.height * 0.2)
                                .transition(.opacity)
                                .onAppear {
                                    audioManager.playAudio(filename: "DayangSumbi1_1")
                                    isDayangDialogueVisible = true
                                    DialogueManager.playDialogue(
                                        text: dayangDialogue,
                                        audio: "DayangSumbi1_1",
                                        audioManager: audioManager,
                                        displayedText: $displayedText,
                                        isTextVisible: $isDayangDialogueVisible
                                    ) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            isNextButtonVisible = true
                                        }
                                    }
                                }
                        }
                        
                        // Narration text
                        if isTextVisible {
                            DialogueTextView(text: displayedText)
                                .frame(width: geo.size.width * 0.95)
                                .offset(y: geo.size.height * 0.35)
                                .onAppear {
                                    startTextAnimation()
                                }
                        }
                        
                        // Dayang's dialogue
                        if isDayangDialogueVisible {
                            DialogueTextView(text: displayedText)
                                .frame(width: geo.size.width * 0.95)
                                .offset(y: geo.size.height * 0.35)
                        }
                        
                        // Next button
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
                        
                        
                                            
                    }
                    
                    .onAppear {
                        audioManager.playAudio(filename: "Narasi1")
                        let narrationDuration = audioManager.audioPlayer?.duration ?? 5
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            isTextVisible = true
                            isSkipVisible = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + narrationDuration - 5) {
                                isTextVisible = false
                                isSkipVisible = false
                                
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    threadPositiony = geo.size.height * 0.75
                                    threadPositionx = geo.size.width * -0.25
                                }
                                
                                withAnimation(.linear(duration: 3.0)) {
                                    isThreadAnimating = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                    isDayangSumbiVisible = true
                                }
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                    .onDisappear {
                        audioManager.stopAudio()
                        threadPositionx = 0
                        threadPositiony = 0
                    }
                    .fullScreenCover(isPresented: $navigateToARView) {
                        ARThreadGameView(state: treasureState)
                    }
                    .forceLandscape()
                }
                .edgesIgnoringSafeArea(.all)
            }
        
        
        private func startTextAnimation() {
            textAnimationTimer = TextAnimation.animateText(
                text: fullText,
                displayedText: $displayedText
            ) {}
        }
    }

    struct CurtainView: View {
        enum Side {
            case left, right
        }
        
        let side: Side
        let offset: CGFloat
        
        var body: some View {
            Rectangle()
                .fill(Color.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: side == .left ? -offset : offset)
                .animation(.easeInOut(duration: 3.0), value: offset)
        }
    }

    extension Animation {
        static func smoothCurtain() -> Animation {
            .interpolatingSpring(stiffness: 100, damping: 15)
        }
    }

    struct Narration1View_Previews: PreviewProvider {
        static var previews: some View {
            Narration1View(showNarrationView: .constant(true))
        }
    }
