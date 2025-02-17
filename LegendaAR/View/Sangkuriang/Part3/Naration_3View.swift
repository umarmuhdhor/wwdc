import SwiftUI
import AVFoundation

struct Narration3View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var displayedText = ""
    @State private var isTextVisible = false
    @State private var isNextButtonVisible = false
    @State private var isDayangSumbiVisible = false
    @State private var isSangkuriangVisible = false
    @State private var navigateToNextScene = false
    @Binding var showNarrationView: Bool
    
    let narrationText = "Sangkuriang grew into a brave and strong young man. He often went hunting in the forest, accompanied by Tumang, unaware that Tumang was his father."
    let dayangSumbiText = "Sangkuriang, go hunt and bring me a deer’s heart for dinner!"
    let sangkuriangText = "Okay, Mom!"
    
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
                                navigateToNextScene = true
                            }
                            .padding(.trailing, 30)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .onAppear {
                audioManager.playAudio(filename: "Narasi3")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    showNarrationText(narrationText) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
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
            .onDisappear {
                audioManager.stopAudio()
            }
            .fullScreenCover(isPresented: $navigateToNextScene) {
                Narration5View(showNarrationView: $navigateToNextScene)
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
        displayedText = text // Langsung tampil semua teks
        audioManager.playAudio(filename: audio)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isTextVisible = false
            completion()
        }
    }
}

struct Narration3View_Previews: PreviewProvider {
    static var previews: some View {
        Narration3View(showNarrationView: .constant(true))
    }
}
