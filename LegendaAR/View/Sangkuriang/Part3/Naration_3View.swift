import SwiftUI
import AVFoundation

struct Narration3View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var displayedText = ""
    @State private var isTextVisible = false
    @State private var isNextButtonVisible = false
    @State private var isDayangSumbiVisible = false
    @State private var isSangkuriangVisible = false
    @State private var showOpeningView4 = false
    @State private var isSkipVisible = false
    @Binding var showNarrationView: Bool
    
    @State private var textAnimationTimer: Timer?
    
    let narrationText = "Sangkuriang grew into a brave and strong young man. He often went hunting in the forest, accompanied by Tumang, unaware that Tumang was his father."
    let dayangSumbiText = "Sangkuriang, go hunt and bring me a deer's heart for dinner!"
    let sangkuriangText = "Okay, Mom!"
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    Image("background_narasi1")
                        .resizable()
                        .scaledToFit ()
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
                            .offset(x: geo.size.width * 0.2, y: geo.size.height * 0.1)
                            .transition(.opacity)
                    }
                    
                    if isTextVisible {
                        DialogueTextView(text: displayedText)
                            .frame(width: geo.size.width * 0.95)
                            .offset(y: geo.size.height * 0.35)
                    }
                    
                    if isSangkuriangVisible {
                        Image("Sangkuriang_Child")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.45)
                            .offset(x: -geo.size.width * 0.2, y: geo.size.height * 0.12)
                            .transition(.opacity)
                    }
                    
                    if isNextButtonVisible {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                NextButton(title: "Next") {
                                    audioManager.stopAudio()
                                    showOpeningView4 = true
                                }
                                .padding(.trailing, geo.size.width * 0.08)
                                .padding(.bottom, geo.size.height * 0.1)
                            }
                        }
                    }
                }
                .onAppear {
                    startNarration()
                }
                .onDisappear {
                    audioManager.stopAudio()
                }
                .fullScreenCover(isPresented: $showOpeningView4) {
                    OpeningView4(showOpeningView: $showOpeningView4)
                }
                .forceLandscape()
            }
        }
    }
    
    // Function to start narration
    private func startNarration() {
        audioManager.playAudio(filename: "Narasi3")
        let narrationDuration = audioManager.audioPlayer?.duration ?? 5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            isTextVisible = true
            isSkipVisible = true
            showNarrationText(narrationText) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    isSkipVisible = false
                    isDayangSumbiVisible = true
                    playDialogue(text: dayangSumbiText, audio: "DayangSumbi3_1") {
                        isSangkuriangVisible = true
                        
                        playDialogue(text: sangkuriangText, audio: "Sangkuriang3_1") {
                            isNextButtonVisible = true
                        }
                    }
                }
            }
        }
    }
    
    // Function to skip narration
    private func skipNarration() {
        // Stop all ongoing processes
        textAnimationTimer?.invalidate()
        textAnimationTimer = nil
        audioManager.stopAudio()
        
        // Reset states
        displayedText = ""
        isTextVisible = false
        isSkipVisible = false
        
        // Skip to Dayang Sumbi's dialogue
        isDayangSumbiVisible = true
        
        // Play Dayang's dialogue immediately
        playDialogue(text: dayangSumbiText, audio: "DayangSumbi3_1") {
            isSangkuriangVisible = true
            
            playDialogue(text: sangkuriangText, audio: "Sangkuriang3_1") {
                isNextButtonVisible = true
            }
        }
    }
    
    // Function to show narration text with animation
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
    
    // Function to play dialogue
    private func playDialogue(text: String, audio: String, completion: @escaping () -> Void) {
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
