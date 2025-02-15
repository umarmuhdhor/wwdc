import SwiftUI
import AVFoundation

struct Narration1_2View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    
    @State private var isDayangSumbiVisible = true
    @State private var isTumangVisible = false
    @State private var isTumangEntering = false
    @State private var displayedText = ""
    @State private var fullTextTumang = "Tumang: \"Dayang Sumbi, here is your thread.\""
    @State private var fullTextDayang = "Dayang Sumbi: \"Thank you, Tumang!\""
    @State private var isTextVisible = false
    @State private var isDayangTextVisible = false
    @State private var isNextButtonVisible = false
    @State private var navigateToARView = false
    @State private var isThreadVisible = false // Benang yang dipegang Tumang
    @State private var isThreadTransferred = false // Benang pindah ke Dayang Sumbi
    
    @Binding var showNarrationView: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("background_narasi1")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                // Dayang Sumbi (selalu terlihat)
                if isDayangSumbiVisible {
                    Image("DayangSumbi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                        .offset(x: 150, y: 100)
                }
                
                // Tumang (Masuk dari kiri)
                if isTumangVisible {
                    Image("Tumang")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                        .offset(x: isTumangEntering ? -150 : -500, y: 100)
                        .transition(.move(edge: .leading))
                }
                
                // Benang di tangan Tumang
                if isThreadVisible && !isThreadTransferred {
                    Image("thread_spool")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .offset(x: isTumangEntering ? -130 : -500, y: 50) // Menyesuaikan dengan posisi Tumang
                }
                
                // Benang di tangan Dayang Sumbi setelah diberikan
                if isThreadTransferred {
                    Image("thread_spool")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .offset(x: 130, y: 50) // Menyesuaikan dengan posisi Dayang Sumbi
                }
                
                // Dialog Tumang
                if isTextVisible {
                    Text(displayedText)
                        .font(.body)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(10)
                        .offset(y: 180)
                }
                
                // Dialog Dayang Sumbi
                if isDayangTextVisible {
                    Text(fullTextDayang)
                        .font(.body)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(10)
                        .offset(y: 180)
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
                
                // Next Button
                if isNextButtonVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NextButton(title: "Next") {
                                audioManager.stopAudio()
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    navigateToARView = true
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
            
        }
    }
    
    private func startScene() {
        // 1. Tumang muncul dan masuk
        isTumangVisible = true
        isThreadVisible = true // Benang terlihat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 1.5)) {
                isTumangEntering = true
            }
        }
        
        // 2. Tumang berbicara
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            playTumangDialogue()
        }
    }
    
    private func playTumangDialogue() {
        audioManager.playAudio(filename: "Tumang_1_1")
        isTextVisible = true
        displayedText = ""
        
        var index = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if index < fullTextTumang.count {
                let character = fullTextTumang[fullTextTumang.index(fullTextTumang.startIndex, offsetBy: index)]
                displayedText.append(character)
                index += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    // 3. Benang berpindah ke Dayang Sumbi
                    isThreadTransferred = true
                    isThreadVisible = false
                    playDayangSumbiDialogue()
                }
            }
        }
    }
    
    private func playDayangSumbiDialogue() {
        audioManager.playAudio(filename: "DayangSumbi_1_1")
        isTextVisible = false
        isDayangTextVisible = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isNextButtonVisible = true
        }
    }
}

// Preview
struct Narration_2View_Previews: PreviewProvider {
    static var previews: some View {
        Narration1_2View(showNarrationView: .constant(true))
    }
}
