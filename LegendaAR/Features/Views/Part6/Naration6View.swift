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
    @State private var isSkipVisible = false // New state for skip button
    @State private var textAnimationTimer: Timer?
    @Binding var showNarrationView: Bool
    
    let narrationText = "Years later, Sangkuriang grew into a handsome and courageous man. Unknowingly, he met a beautiful woman who turned out to be his mother, Dayang Sumbi."
    let sangkuriangText1 = "You look very beautiful, Dayang Sumbi. Will you marry me?"
    let dayangSumbiText1 = "I cannot marry you, Sangkuriang!"
    let sangkuriangText2 = "But I truly want to marry you, Dayang Sumbi. I will do anything!"
    let dayangSumbiText2 = "Well. If you really want to marry me, then dam the Citarum River and build me a giant boat before sunrise tomorrow."
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("background_narasi1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
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
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                
                if isDayangSumbiVisible {
                    Image("DayangSumbi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                        .offset(x: 150, y: 100)
                        .transition(.opacity)
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
                }
                
                if isSangkuriangVisible {
                    Image("Sangkuriang")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350)
                        .offset(x: -150, y: 120)
                        .transition(.opacity)
                }
                
                if isNextButtonVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NextButton(title: "Build a boat") {
                                audioManager.stopAudio()
                                showPuzzleGame = true
                            }
                            .padding(.trailing, 30)
                            .padding(.bottom, 30)
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
        isSkipVisible = true // Show skip button when narration starts
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            showNarrationText(narrationText) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                    isSangkuriangVisible = true
                    
                    playDialogue(text: sangkuriangText1, audio: "Sangkuriang6_1") {
                        isDayangSumbiVisible = true
                        
                        playDialogue(text: dayangSumbiText1, audio: "DayangSumbi6_1") {
                            playDialogue(text: sangkuriangText2, audio: "Sangkuriang6_2") {
                                playDialogue(text: dayangSumbiText2, audio: "DayangSumbi6_2") {
                                    isNextButtonVisible = true
                                    isSkipVisible = false // Hide skip button when narration ends
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func showNarrationText(_ text: String, completion: @escaping () -> Void) {
        isTextVisible = true
        displayedText = ""
        var index = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if index < text.count {
                let character = text[text.index(text.startIndex, offsetBy: index)]
                displayedText.append(character)
                index += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isTextVisible = false
                    completion()
                }
            }
        }
    }
    
    private func playDialogue(text: String, audio: String, completion: @escaping () -> Void) {
        isTextVisible = true
        displayedText = text
        audioManager.playAudio(filename: audio)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isTextVisible = false
            completion()
        }
    }
}
