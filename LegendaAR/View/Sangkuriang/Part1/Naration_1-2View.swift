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
    
    // Quiz states
    @State private var showQuiz = false
    @State private var timeRemaining = 10
    @State private var timer: Timer?
    @State private var showIncorrectAnswer = false
    @State private var showCorrectAnswer = false
    
    // Constants for dialogue
    private let tumangDialogue = "Dayang Sumbi, here is your thread"
    private let dayangDialogue = "Thank you, Tumang. As I promised, I will marry you."
    
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
                    
                    // Quiz overlay
                    if showQuiz {
                        Color.black
                            .opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 20) {
                            // Timer circle in top left
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                    
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 3)
                                        .frame(width: 60, height: 60)
                                    
                                    Text("\(timeRemaining)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .padding(.leading, 30)
                                .padding(.top, 20)
                                
                                Spacer()
                            }
                            
                            Spacer()
                                .frame(height: 40)
                            
                            Text("What should Dayang Sumbi do after finding out that her servant retrieved her thread?")
                                .font(.system(size: 24, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                            
                            Spacer()
                                .frame(height: 40)
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    audioManager.playAudio(filename: "right")
                                    handleAnswer(correct: true)
                                }) {
                                    Text("Fulfill her promise")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(Color.blue.opacity(0.8))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                }
                                
                                Button(action: {
                                    audioManager.playAudio(filename: "wrong")
                                    handleAnswer(correct: false)
                                }) {
                                    Text("Break her promise and reject him")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(Color.blue.opacity(0.8))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                }
                            }
                            .padding(.horizontal, 40)
                            
                            Spacer()
                        }
                    }
                    
                    // Incorrect answer overlay
                    if showIncorrectAnswer {
                        Color.black
                            .opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        
                        Text("Wrong Answer! Dayang Sumbi must fulfill her promise.")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(30)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .padding(.horizontal, 40)
                    }
                    
                    if showCorrectAnswer {
                        Color.black
                            .opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        
                        Text("RIGHT !!! Dayang sumbi fulfill her promise")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(30)
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .padding(.horizontal, 40)
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
            startQuiz()
        }
    }
    
    private func startQuiz() {
        showQuiz = true
        timeRemaining = 10
        audioManager.playAudio(filename: "sec")
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining > 0 { 
                    audioManager.playAudio(filename: "sec")
                }
            } else {
                audioManager.playAudio(filename: "wrong")
                handleAnswer(correct: false)
            }
        }
    }
    
    private func handleAnswer(correct: Bool) {
        timer?.invalidate()
        timer = nil
        
        if correct {
            showQuiz = false
            showCorrectAnswer = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                showCorrectAnswer = false
                playDayangSumbiDialogue()
            }
        } else {
            showQuiz = false
            showIncorrectAnswer = true
            audioManager.playAudio(filename: "wrong")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                showIncorrectAnswer = false
                playDayangSumbiDialogue()
            }
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
