import SwiftUI
import AVFoundation

struct Narration5View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    
    @State private var isSangkuriangVisible = true
    @State private var isDayangSumbiVisible = true
    @State private var displayedText = ""
    @State private var isTextVisible = false
    @State private var isSangkuriangTextVisible = false
    @State private var isDayangTextVisible = false
    @State private var isNextButtonVisible = false
    @State private var navigateToNextView = false
    @State private var isHeartVisible = false
    @State private var isHeartTransferred = false
    @State private var showQuiz = false
    @State private var timeRemaining = 10
    @State private var timer: Timer?
    @State private var showIncorrectAnswer = false
    @State private var showCorrectAnswer = false
    
    private let sangkuriangText1 = "Here is the deer's heart, Mom!"
    private let dayangSumbiText1 = "Wow, thank you, my son! But where is Tumang?"
    private let sangkuriangText2 = "Hmm... Sorry, Mom, actually, this is Tumang's heart."
    private let dayangSumbiText2 = "What?! You must be joking!"
    
    @Binding var showNarrationView: Bool
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    Image("background_part3")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .edgesIgnoringSafeArea(.all)
                    
                    if isDayangSumbiVisible {
                        Image("DayangSumbi")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.3)
                            .offset(x: geo.size.width * 0.2, y: geo.size.height * 0.2)
                    }
                    
                    if isSangkuriangVisible {
                        Image("Sangkuriang_Child")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.25)
                            .offset(x: -geo.size.width * 0.2, y: geo.size.height * 0.35)
                    }
                    
                    if isHeartVisible && !isHeartTransferred {
                        Image("heart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.1)
                            .offset(x: geo.size.width * -0.2, y: geo.size.height * 0.35)
                            .transition(.move(edge: .leading))
                    }
                    
                    if isHeartTransferred {
                        Image("heart")
                        
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.1)
                        .offset(x: geo.size.width * 0.2, y: geo.size.height * 0.1)
                        .transition(.opacity)
                    }
                    
                    if showQuiz {
                        Color.black
                            .opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
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
                            
                            VStack(spacing: 30) {
                                Text("Why was Dayang Sumbi angry at Sangkuriang?")
                                    .font(.system(size: 24, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                                
                                VStack(spacing: 20) {
                                    Button(action: {
                                        handleAnswer(correct: false)
                                    }) {
                                        Text("Sangkuriang didn't bring deer's heart")
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
                                        handleAnswer(correct: true)
                                    }) {
                                        Text("Sangkuriang killed Tumang")
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
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    if showIncorrectAnswer {
                        Color.black
                            .opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                        
                        Text("Dayang Sumbi was angry because Sangkuriang killed Tumang.")
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
                        
                        Text("Dayang Sumbi was angry because Sangkuriang killed Tumang.")
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
                    
                    if isTextVisible || isDayangTextVisible || isSangkuriangTextVisible {
                        DialogueTextView(text: displayedText)
                            .offset(y: geo.size.height * 0.3)
                    }
                    
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
                                    navigateToNextView = true
                                }
                                .padding(.trailing, geo.size.width * 0.08)
                                .padding(.bottom, geo.size.height * 0.1)
                            }
                        }
                    }
                }
                .onAppear { startScene() }
                .edgesIgnoringSafeArea(.all)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $navigateToNextView) {
            OpeningView6(showOpeningView: $navigateToNextView)
        }
        .onDisappear {
            audioManager.stopAudio()
        }
    }
    
    private func startScene() {
        isHeartVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 1.5)) {
                isHeartTransferred = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            playSangkuriangDialogue1()
        }
    }
    
    private func playSangkuriangDialogue1() {
        DialogueManager.playDialogue(
            text: sangkuriangText1,
            audio: "Sangkuriang5_1",
            audioManager: audioManager,
            displayedText: $displayedText,
            isTextVisible: $isSangkuriangTextVisible
        ) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                playDayangSumbiDialogue1()
            }
        }
    }
    
    private func playDayangSumbiDialogue1() {
        DialogueManager.playDialogue(
            text: dayangSumbiText1,
            audio: "DayangSumbi5_1",
            audioManager: audioManager,
            displayedText: $displayedText,
            isTextVisible: $isDayangTextVisible
        ) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                playSangkuriangDialogue2()
            }
        }
    }
    
    private func playSangkuriangDialogue2() {
        DialogueManager.playDialogue(
            text: sangkuriangText2,
            audio: "Sangkuriang5_2",
            audioManager: audioManager,
            displayedText: $displayedText,
            isTextVisible: $isSangkuriangTextVisible
        ) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                playDayangSumbiDialogue2()
            }
        }
    }
    
    private func playDayangSumbiDialogue2() {
        DialogueManager.playDialogue(
            text: dayangSumbiText2,
            audio: "DayangSumbi5_2",
            audioManager: audioManager,
            displayedText: $displayedText,
            isTextVisible: $isDayangTextVisible
        ) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                startQuiz()
            }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showCorrectAnswer = false
                isNextButtonVisible = true
            }
        } else {
            showQuiz = false
            showIncorrectAnswer = true
            audioManager.playAudio(filename: "wrong")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                showIncorrectAnswer = false
                isNextButtonVisible = true
            }
        }
    }
}

struct Narration5View_Previews: PreviewProvider {
    static var previews: some View {
        Narration5View(showNarrationView: .constant(true))
    }
}
