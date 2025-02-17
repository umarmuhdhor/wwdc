import SwiftUI
import AVFoundation

struct Narration5View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var displayedText = ""
    @State private var isTextVisible = false
    @State private var isNextButtonVisible = false
    @State private var isDayangSumbiVisible = false
    @State private var isSangkuriangVisible = false
    @Binding var showNarrationView: Bool
    
    let dialogue: [(text: String, audio: String, showDayangSumbi: Bool, showSangkuriang: Bool)] = [
        ("Here is the deer’s heart, Mom!", "Sangkuriang5_1", false, true),
        ("Wow, thank you, my son! But where is Tumang?", "DayangSumbi5_1", true, false),
        ("Hmm... Sorry, Mom, actually, this is Tumang’s heart.", "Sangkuriang5_2", false, true),
        ("What?! You must be joking!", "DayangSumbi5_2", true, false)
    ]
    
    @State private var currentDialogueIndex = 0
    
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
                
                if isSangkuriangVisible {
                    Image("Sangkuriang")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350)
                        .offset(x: -150, y: 120)
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
                playNextDialogue()
            }
            .onDisappear {
                audioManager.stopAudio()
            }
            .forceLandscape()
        }
    }
    
    private func playNextDialogue() {
        if currentDialogueIndex < dialogue.count {
            let current = dialogue[currentDialogueIndex]
            isDayangSumbiVisible = current.showDayangSumbi
            isSangkuriangVisible = current.showSangkuriang
            isTextVisible = true
            displayedText = current.text
            audioManager.playAudio(filename: current.audio)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isTextVisible = false
                currentDialogueIndex += 1
                playNextDialogue()
            }
        } else {
            isNextButtonVisible = true
        }
    }
}

struct Narration5View_Previews: PreviewProvider {
    static var previews: some View {
        Narration5View(showNarrationView: .constant(true))
    }
}
