import SwiftUI
import AVFoundation

struct Narration6View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var displayedText = ""
    @State private var isTextVisible = false
    @State private var isNextButtonVisible = false
    @State private var isDayangSumbiVisible = false
    @State private var isSangkuriangVisible = false
    @Binding var showNarrationView: Bool
    
    let narrationText = "Years later, Sangkuriang grew into a handsome and courageous man. Unknowingly, he met a beautiful woman who turned out to be his mother, Dayang Sumbi."
    let sangkuriangText1 = "You look very beautiful, Dayang Sumbi. Will you marry me?"
    let dayangSumbiText1 = "I cannot marry you, Sangkuriang!"
    let sangkuriangText2 = "But I truly want to marry you, Dayang Sumbi. I will do anything!"
    let dayangSumbiText2 = "Well. If you really want to marry me, then dam the Citarum River and build me a giant boat before sunrise tomorrow."
    
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
                            NextButton(title: "Next") {
                                audioManager.stopAudio()
                                showNarrationView = false
                            }
                            .padding(.trailing, 30)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .onAppear {
                audioManager.playAudio(filename: "Narasi6")
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    showNarrationText(narrationText) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
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
                    }
                }
            }
            .onDisappear {
                audioManager.stopAudio()
            }
            .forceLandscape()
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
        displayedText = text // Instantly display all text
        audioManager.playAudio(filename: audio)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isTextVisible = false
            completion()
        }
    }
}

struct Narration6View_Previews: PreviewProvider {
    static var previews: some View {
        Narration6View(showNarrationView: .constant(true))
    }
}
