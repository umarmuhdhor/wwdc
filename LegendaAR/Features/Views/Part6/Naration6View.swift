import SwiftUI
import AVFoundation

struct Narration6View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var displayedText = ""
    @State private var isTextVisible = false
    @State private var isNextButtonVisible = false
    @State private var isDayangSumbiVisible = false
    @State private var isSangkuriangVisible = false
    @State private var showPuzzleGame = false
    @State private var isSkipVisible = false
    @State private var isNarrationSkipped = false
    @State private var isDialogDone = false
    @Binding var showNarrationView: Bool
    
    @State private var textAnimationTimer: Timer?
    
    let narrationText = "Years later, Sangkuriang grew into a handsome and courageous man. Unknowingly, he met a beautiful woman who turned out to be his mother, Dayang Sumbi."
    let sangkuriangText1 = "You look very beautiful, Dayang Sumbi. Will you marry me?"
    let dayangSumbiText1 = "I cannot marry you, Sangkuriang!"
    let sangkuriangText2 = "But I truly want to marry you, Dayang Sumbi. I will do anything!"
    let dayangSumbiText2 = "Well. If you really want to marry me, then dam the Citarum River and build me a giant boat before sunrise tomorrow."
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("background_part4")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        if isSkipVisible {
                            NextButton(title: "Skip Narration") {
                                skipNarration()
                            }
                        }
                        
                        Spacer()
                        
                        CloseButton(isPresented: $showNarrationView)
                            .onTapGesture {
                                audioManager.stopAudio()
                                isDialogDone = true
                                showNarrationView = false
                            }
                    }
                    .padding(.top, geo.size.height * 0.02)
                    .padding(.horizontal, geo.size.width * 0.05)
                    Spacer()
                }
                
                if isDayangSumbiVisible {
                    Image("DayangSumbi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.3)
                        .offset(x: geo.size.width * 0.2, y: geo.size.height * 0.2)
                        .transition(.opacity)
                }
                
                if isSangkuriangVisible {
                    Image("Sangkuriang")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.45)
                        .offset(x: -geo.size.width * 0.1, y: geo.size.height * 0.15)
                        .transition(.opacity)
                }
                
                if isTextVisible {
                    DialogueTextView(text: displayedText)
                        .frame(width: geo.size.width * 0.95)
                        .offset(y: geo.size.height * 0.35)
                }
                

                
                if isNextButtonVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NextButton(title: "Next") {
                                audioManager.stopAudio()
                                showPuzzleGame = true
                            }
                            .padding(.trailing, geo.size.width * 0.08)
                            .padding(.bottom, geo.size.height * 0.1)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                startNarration()
            }
            .onDisappear {
                audioManager.stopAudio()
            }
            .fullScreenCover(isPresented: $showPuzzleGame) {
                ShipPuzzleGameView(showPuzzleView: $showPuzzleGame)
            }
            .forceLandscape()
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func startNarration() {
        audioManager.playAudio(filename: "Narasi6")
        let narrationDuration = audioManager.audioPlayer?.duration ?? 5
        guard !isNarrationSkipped else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            isTextVisible = true
            isSkipVisible = true
            showNarrationText(narrationText) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    isSkipVisible = false
                    isSangkuriangVisible = true
                    
                    guard !isDialogDone else { return }
                    playDialogue(text: sangkuriangText1, audio: "Sangkuriang6_1") {
                        isDayangSumbiVisible = true
                        guard !isDialogDone else { return }
                        playDialogue(text: dayangSumbiText1, audio: "DayangSumbi6_1") {
                            guard !isDialogDone else { return }
                            playDialogue(text: sangkuriangText2, audio: "Sangkuriang6_2") {
                                guard !isDialogDone else { return }
                                playDialogue(text: dayangSumbiText2, audio: "DayangSumbi6_2") {
                                    isNextButtonVisible = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func skipNarration() {
        textAnimationTimer?.invalidate()
        textAnimationTimer = nil
        audioManager.stopAudio()
        isNarrationSkipped = true
        displayedText = ""
        isTextVisible = false
        isSkipVisible = false
        
        
        isSangkuriangVisible = true
        playDialogue(text: sangkuriangText1, audio: "Sangkuriang6_1") {
            isDayangSumbiVisible = true
            playDialogue(text: dayangSumbiText1, audio: "DayangSumbi6_1") {
                playDialogue(text: sangkuriangText2, audio: "Sangkuriang6_2") {
                    playDialogue(text: dayangSumbiText2, audio: "DayangSumbi6_2") {
                        isNextButtonVisible = true
                    }
                }
            }
        }
    }
    
    private func showNarrationText(_ text: String, completion: @escaping () -> Void) {
        isTextVisible = true
        displayedText = ""
        
        textAnimationTimer?.invalidate()
        var index = 0
        
        textAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if index < text.count {
                let character = text[text.index(text.startIndex, offsetBy: index)]
                displayedText.append(character)
                index += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                    isTextVisible = false
                    completion()
                }
            }
        }
    }
    
    private func playDialogue(text: String, audio: String, completion: @escaping () -> Void) {
        audioManager.stopAudio()
        isTextVisible = true
        displayedText = text
        audioManager.playAudio(filename: audio)
        let duration = audioManager.audioPlayer?.duration ?? 5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            isTextVisible = false
            completion()
        }
    }
}
