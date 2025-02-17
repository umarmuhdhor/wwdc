import SwiftUI

struct Narration2View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    
    @State private var isSangPrabuVisible = true
    @State private var isDayangSumbiVisible = true
    @State private var isTumangHumanVisible = false
    @State private var isTumangDogVisible = false
    @State private var displayedText = ""
    @State private var isTextVisible = false
    @State private var isNextButtonVisible = false
    @State private var navigateToNextScene = false
    
    @Binding var showNarrationView: Bool
    
    let fullTextSangPrabu1 = "Dayang Sumbi! Who is the man who has made you pregnant?"
    let fullTextTumang = "Forgive me, Your Majesty, but I am the one who has committed this forbidden act."
    let fullTextSangPrabu2 = "You dare dishonor the kingdom? I curse you to become a dog"
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("background_part2")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                if isSangPrabuVisible {
                    Image("SangPrabu")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350)
                        .offset(x: -200, y: 70)
                }
                
                if isDayangSumbiVisible {
                    Image("DayangSumbi_Hamil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500)
                        .offset(x: 160, y: 100)
                }
                
                if isTumangHumanVisible {
                    Image("Tumang")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .offset(x: 250, y: 100)
                        .transition(.move(edge: .trailing))
                }
                
                if isTumangDogVisible {
                    Image("Tumang_dog")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .offset(x: 230, y: 160)
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
                        .offset(y: 160)
                }
                
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
                
                if isNextButtonVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NextButton(title: "Next") {
                                audioManager.stopAudio()
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    navigateToNextScene = true
                                }
                            }
                            .padding(.trailing, 30)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .onAppear {
                startScene()
            }
            .onDisappear {
                audioManager.stopAudio()
            }.fullScreenCover(isPresented: $navigateToNextScene) {
                Narration3View(showNarrationView: $navigateToNextScene)
            }
        }
    }
    
    private func startScene() {
        DialogueManager.playDialogue(
            text: fullTextSangPrabu1,
            audio: "SangPrabu_1",
            audioManager: audioManager,
            displayedText: $displayedText,
            isTextVisible: $isTextVisible
        ) {
            withAnimation(.easeInOut(duration: 1.0)) {
                isTumangHumanVisible = true
            }
            DialogueManager.playDialogue(
                text: fullTextTumang,
                audio: "Tumang_2",
                audioManager: audioManager,
                displayedText: $displayedText,
                isTextVisible: $isTextVisible
            ) {
                DialogueManager.playDialogue(
                    text: fullTextSangPrabu2,
                    audio: "SangPrabu_2",
                    audioManager: audioManager,
                    displayedText: $displayedText,
                    isTextVisible: $isTextVisible
                ) {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        isTumangHumanVisible = false
                        isTumangDogVisible = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        isNextButtonVisible = true
                    }
                }
            }
        }
    }
}

// Preview
struct Narration2View_Previews: PreviewProvider {
    static var previews: some View {
        Narration2View(showNarrationView: .constant(true))
    }
}
