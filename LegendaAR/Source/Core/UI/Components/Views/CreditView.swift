import SwiftUI

struct CreditView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            
            Text("Credits")
                .font(.largeTitle)
                .bold()
                .padding(.top, 10)
                
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("App Development")
                            .font(.title2)
                            .bold()
                        
                        Text("- Built with SwiftUI and Xcode")
                        Text("- Audio handled using AVFoundation")
                        Text("- Story content inspired by Indonesian folklore")
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Assets and Tools")
                            .font(.title2)
                            .bold()
                        
                        Text("- Images generated using **Leonardo.AI**")
                        Text("- 3D models created with **Meshy.AI**")
                        Text("- Dialog audio generated using **ElevenLabs**")
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Audio Credits")
                            .font(.title2)
                            .bold()
                        
                        Text("- Background music: [YouTube Link](https://youtu.be/q-gp58dQiSQ?si=yVzF-GJpONWplBRP)")
                        Text("- Clock sound effect: [YouTube Link](https://youtu.be/J0sTjeK92gI?si=8Qt2sxqktBGTPej_)")
                        Text("- Lose sound effect: [YouTube Link](https://youtu.be/CQeezCdF4mk?si=TZeaSmHIGCmr66YY)")
                        Text("- Winning sound effect: [YouTube Link](https://youtu.be/rr5CMS2GtCY?si=8hZ9Z_aEPeH5bMP6)")
                    }
                      
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Special Thanks")
                            .font(.title2)
                            .bold()
                        
                        Text("- Open Source Libraries")
                        Text("- Community Contributors")
                        Text("- Beta Testers")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
        }
        .background(Color(.systemGray6))
        .navigationBarHidden(true)
    }
}

struct CreditView_Previews: PreviewProvider {
    static var previews: some View {
        CreditView()
    }
}
