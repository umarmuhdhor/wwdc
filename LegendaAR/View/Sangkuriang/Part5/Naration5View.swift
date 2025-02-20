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
    
    @State private var textAnimationTimer: Timer?
    
    let sangkuriangText1 = "Here is the deer’s heart, Mom!"
    let dayangSumbiText1 = "Wow, thank you, my son! But where is Tumang?"
    let sangkuriangText2 = "Hmm... Sorry, Mom, actually, this is Tumang’s heart."
    let dayangSumbiText2 = "What?! You must be joking!"
    
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
                isSangkuriangVisible = true
                playDialogue(text: sangkuriangText1, audio: "Sangkuriang5_1") {
                    isDayangSumbiVisible = true
                    playDialogue(text: dayangSumbiText1, audio: "DayangSumbi5_1") {
                        playDialogue(text: sangkuriangText2, audio: "Sangkuriang5_2") {
                            playDialogue(text: dayangSumbiText2, audio: "DayangSumbi5_2") {
                                isNextButtonVisible = true
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
    
    private func playDialogue(text: String, audio: String, completion: @escaping () -> Void) {
        isTextVisible = true
        displayedText = text
        audioManager.playAudio(filename: audio)
        let narrationDuration = audioManager.audioPlayer?.duration ?? 5
        DispatchQueue.main.asyncAfter(deadline: .now() + narrationDuration) {
            isTextVisible = false
            completion()
        }
    }
}

struct Narration5View_Previews: PreviewProvider {
    static var previews: some View {
        Narration5View(showNarrationView: .constant(true))
    }
}
