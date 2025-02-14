import SwiftUI
import AVFoundation

struct Narration1_2View: View {
    @StateObject private var audioManager = AudioPlayerManager()
    
    @State private var isDayangSumbiVisible = true
    @State private var isTumangVisible = true
    @State private var displayedText = ""
    @State private var isTextVisible = false
    @State private var isNextButtonVisible = false
    @State private var navigateToARView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("background_narasi1")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                // Karakter Tumang
                if isTumangVisible {
                    Image("DayangSumbi_2D")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350)
                        .offset(x: -100, y: 150)
                        .transition(.opacity)
                }
                
                // Karakter Dayang Sumbi
                if isDayangSumbiVisible {
                    Image("DayangSumbi_2D")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                        .offset(x: 150, y: 100)
                        .transition(.opacity)
                }
                
                // Dialog teks
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
                
                // Tombol Next di pojok kanan bawah
                if isNextButtonVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                navigateToARView = true
                            }) {
                                Text("Next")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 100)
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .onAppear {
                playConversation()
            }
            .background(
                NavigationLink(
                    destination: ARViewContainer(),
                    isActive: $navigateToARView,
                    label: { EmptyView() }
                )
            )
        }
    }
    
    private func playConversation() {
        // Step 1: Putar suara Tumang dulu
        audioManager.playAudio(filename: "Tumang_Audio")
        
        // Step 2: Setelah suara Tumang selesai, ganti ke suara Dayang Sumbi
        DispatchQueue.main.asyncAfter(deadline: .now() + (audioManager.audioPlayer?.duration ?? 4)) {
            isTextVisible = false // Hapus teks sebelumnya
            isTumangVisible = false // Sembunyikan Tumang setelah berbicara
            
            audioManager.playAudio(filename: "DayangSumbi_Audio")
            displayedText = "Oh Tumang, bagaimana ini?" // Teks dialog Dayang Sumbi
            isTextVisible = true
            
            // Step 3: Setelah Dayang Sumbi selesai bicara, tampilkan tombol Next
            DispatchQueue.main.asyncAfter(deadline: .now() + (audioManager.audioPlayer?.duration ?? 6)) {
                isTextVisible = false // Hapus teks setelah bicara
                isNextButtonVisible = true
            }
        }
    }
}

// Preview
struct Narration_2View_Previews: PreviewProvider {
    static var previews: some View {
        Narration1_2View()
    }
}
