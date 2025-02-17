import SwiftUI
import AVFoundation

struct Narration1_2View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    
    @State private var isDayangSumbiVisible = true
    @State private var isTumangVisible = false
    @State private var isTumangEntering = false
    @State private var displayedText = ""
    @State private var isTextVisible = false
    @State private var isDayangTextVisible = false
    @State private var isNextButtonVisible = false
    @State private var navigateToARView = false
    @State private var isThreadVisible = false
    @State private var isThreadTransferred = false
    @State private var showOpeningView2 = false
    
    // Constants for dialogue
    private let tumangDialogue = "Tumang: \"Dayang Sumbi, here is your thread.\""
    private let dayangDialogue = "Dayang Sumbi: \"Thank you, Tumang. As I promised, I will marry you.\""
    
    @Binding var showNarrationView: Bool
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    // Background
                    Image("background_narasi1")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    
                    // Character Images
                    if isDayangSumbiVisible {
                        Image("DayangSumbi")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.5)
                            .offset(x: geo.size.width * 0.2, y: geo.size.height * 0.2)
                    }
                    
                    if isTumangVisible {
                        Image("Tumang")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.5)
                            .offset(x: isTumangEntering ? geo.size.width * -0.2 : geo.size.width * -0.5,
                                   y: geo.size.height * 0.2)
                            .transition(.move(edge: .leading))
                    }
                    
                    // Thread Images
                    if isThreadVisible && !isThreadTransferred {
                        Image("thread_spool")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.15)
                            .offset(x: isTumangEntering ? geo.size.width * -0.2 : geo.size.width * -0.5,
                                   y: geo.size.height * 0.1)
                    }
                    
                    if isThreadTransferred {
                        Image("thread_spool")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.15)
                            .offset(x: geo.size.width * 0.2, y: geo.size.height * 0.1)
                    }
                    
                    // Dialogue Text Views
                    if isTextVisible || isDayangTextVisible {
                        DialogueTextView(text: displayedText)
                            .offset(y: geo.size.height * 0.3)
                    }
                    
                    // UI Controls
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
                    
                    if isNextButtonVisible {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                NextButton(title: "Next") {
                                    audioManager.stopAudio()
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showOpeningView2 = true
                                    }
                                }
                                .padding(.trailing, geo.size.width * 0.08)
                                .padding(.bottom, geo.size.height * 0.1)
                            }
                        }
                    }
                }
                .onAppear { startScene() }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showOpeningView2) {
            OpeningView2(showOpeningView: $showOpeningView2) 
        }
    }
    
    private func startScene() {
        isTumangVisible = true
        isThreadVisible = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 1.5)) {
                isTumangEntering = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            playTumangDialogue()
        }
    }
    
    private func playTumangDialogue() {
        DialogueManager.playDialogue(
            text: tumangDialogue,
            audio: "Tumang1_1",
            audioManager: audioManager,
            displayedText: $displayedText,
            isTextVisible: $isTextVisible
        ) {
            isThreadTransferred = true
            isThreadVisible = false
            playDayangSumbiDialogue()
        }
    }
    
    private func playDayangSumbiDialogue() {
        DialogueManager.playDialogue(
            text: dayangDialogue,
            audio: "DayangSumbi1_2",
            audioManager: audioManager,
            displayedText: $displayedText,
            isTextVisible: $isDayangTextVisible
        ) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isNextButtonVisible = true
            }
        }
    }
}



struct Narration_2View_Previews: PreviewProvider {
    static var previews: some View {
        Narration1_2View(showNarrationView: .constant(true))
    }
}
