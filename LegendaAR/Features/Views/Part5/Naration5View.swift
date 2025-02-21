import SwiftUI
import AVFoundation

struct Narration5View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var displayedText = ""
    @State private var isTextVisible = false
    @State private var isNextButtonVisible = false
    @State private var isDayangSumbiVisible = false
    @State private var isSangkuriangVisible = false
    @State private var navigateNextView = false
    
    // Quiz states
    @State private var showQuiz = false
    @State private var timeRemaining = 10
    @State private var timer: Timer?
    @State private var showIncorrectAnswer = false
    @State private var showCorrectAnswer = false
    
    @Binding var showNarrationView: Bool
    
    
    let sangkuriangText1 = "Here is the deer's heart, Mom!"
    let dayangSumbiText1 = "Wow, thank you, my son! But where is Tumang?"
    let sangkuriangText2 = "Hmm... Sorry, Mom, actually, this is Tumang's heart."
    let dayangSumbiText2 = "What?! You must be joking!"
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("background_narasi1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
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
                    Image("Sangkuriang_Child")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350)
                        .offset(x: -150, y: 120)
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
                        
                        Text("Why was Dayang Sumbi angry at Sangkuriang?")
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
                                Text("Sangkuriang didn't bring deer's heart")
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
                                Text("Sangkuriang killed Tumang")
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
                    }
                }
                
                // Incorrect answer overlay
                if showIncorrectAnswer {
                    Color.black
                        .opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    
                    Text("Wrong Answer! Dayang Sumbi was angry because Sangkuriang killed Tumang.")
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
                    
                    Text("Correct! Dayang Sumbi was angry because Sangkuriang killed Tumang!")
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
                
                if isNextButtonVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NextButton(title: "Next") {
                                audioManager.stopAudio()
                                navigateNextView = true
                            }
                            .padding(.trailing, 30)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                isSangkuriangVisible = true
                playDialogue(text: sangkuriangText1, audio: "Sangkuriang5_1") {
                    isDayangSumbiVisible = true
                    playDialogue(text: dayangSumbiText1, audio: "DayangSumbi5_1") {
                        playDialogue(text: sangkuriangText2, audio: "Sangkuriang5_2") {
                            playDialogue(text: dayangSumbiText2, audio: "DayangSumbi5_2") {
                                startQuiz()
                            }
                        }
                    }
                }
            }
            .onDisappear {
                audioManager.stopAudio()
                timer?.invalidate()
                timer = nil
            }
            .fullScreenCover(isPresented: $navigateNextView) {
                Narration6View(showNarrationView: $navigateNextView)
            }
            .forceLandscape()
            
        }
        .edgesIgnoringSafeArea(.all)
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
