import SwiftUI
import AVFoundation

struct Narration1View: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isThreadFalling = false
    @State private var isDayangSumbiVisible = false
    @State private var isNextButtonVisible = false
    
    var body: some View {
        ZStack {
            Image("background_narasi1")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                if isThreadFalling {
                    Image("thread_spool")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .offset(y: isThreadFalling ? 400 : -200)
                        .animation(.easeIn(duration: 1.5), value: isThreadFalling)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                isDayangSumbiVisible = true
                                playAudio(filename: "DayangSumbi_1")
                            }
                        }
                }

                if isDayangSumbiVisible {
                    Image("dayang_sumbi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                isNextButtonVisible = true
                            }
                        }
                }

                Spacer()

                // Narasi teks
                if !isThreadFalling {
                    Text("Long ago, in the lush lands of Sunda, there lived a beautiful princess named Dayang Sumbi. She was known for her unmatched beauty and extraordinary skill in weaving.")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }

                Spacer()

                if isNextButtonVisible {
                    Button("Find the Thread") {
                        // Aksi lanjut ke permainan mencari benang
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .onAppear {
            playAudio(filename: "Narasi1_fix")
        }
    }

    // Fungsi untuk memainkan audio
    func playAudio(filename: String) {
        if let path = Bundle.main.path(forResource: filename, ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + (audioPlayer?.duration ?? 5)) {
                    isThreadFalling = true
                }
            } catch {
                print("Error playing audio file: \(filename)")
            }
        }
    }
}

struct Narration1View_Previews: PreviewProvider {
    static var previews: some View {
        Narration1View()
    }
}
