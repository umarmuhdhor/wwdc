import SwiftUI
import AVFoundation

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
    
    // Quiz states
    @State private var showQuiz = false
    @State private var timeRemaining = 10
    @State private var timer: Timer?
    @State private var showIncorrectAnswer = false
    @State private var showCorrectAnswer = false
    
    @Binding var showNarrationView: Bool
    
    let fullTextSangPrabu1 = "Dayang Sumbi! Who is the man who has made you pregnant?"
    let fullTextTumang = "Forgive me, Your Majesty, but I am the one who has committed this forbidden act."
    let fullTextSangPrabu2 = "You dare dishonor the kingdom? I curse you to become a dog!"
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    // Background
                    Image("background_part2")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    
                    // Character Images
                    if isSangPrabuVisible {
                        Image("SangPrabu")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.5)
                            .offset(x: -geo.size.width * 0.25, y: geo.size.height * 0.15)
                    }
                    
                    if isDayangSumbiVisible {
                        Image("DayangSumbi")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.4)
                            .offset(x: geo.size.width * 0.2, y: geo.size.height * 0.2)
                    }
                    
                    if isTumangHumanVisible {
                        Image("Tumang")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.5)
                            .offset(x: geo.size.width * 0.35, y: geo.size.height * 0.2)
                            .transition(.move(edge: .trailing))
                    }
                    
                    if isTumangDogVisible {
                        Image("Tumang_dog")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.25)
                            .offset(x: geo.size.width * 0.35, y: geo.size.height * 0.32)
                            .transition(.opacity)
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
                            
                            Text("Will Tumang admit his mistake?")
                                .font(.system(size: 24, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                            
                            Spacer()
                                .frame(height: 40)
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    handleAnswer(correct: false)
                                }) {
                                    Text("Ignore the situation and avoid responsibility")
                                        .font(.system(size: 24, weight: .bold))
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
                                    handleAnswer(correct: true)
                                }) {
                                    Text("Take responsibility for his actions")
                                        .font(.system(size: 24, weight: .bold))
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
                        
                        Text("Wrong Answer! Tumang must responsibility for his actions")
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
                        
                        Text("RIGHT !!! Tumang Take responsibility for his actions")
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
                    if isTextVisible {
                        Text(displayedText)
                            .font(.body)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(10)
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
                                        navigateToNextScene = true
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
        .fullScreenCover(isPresented: $navigateToNextScene) {
            Narration3View(showNarrationView: $navigateToNextScene)
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
            audioManager.playAudio(filename: "right")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showCorrectAnswer = false
                continueTumangDialogue()
            }
        } else {
            showQuiz = false
            showIncorrectAnswer = true
            audioManager.playAudio(filename: "wrong")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                showIncorrectAnswer = false
                continueTumangDialogue()
            }
        }
    }
    
    private func continueTumangDialogue() {
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

struct Narration2View_Previews: PreviewProvider {
    static var previews: some View {
        Narration2View(showNarrationView: .constant(true))
    }
}
