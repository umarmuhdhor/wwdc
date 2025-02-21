import SwiftUI

struct CreditView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Credits")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
            
            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // App Development
                    VStack(alignment: .leading, spacing: 10) {
                        Text("App Development")
                            .font(.title2)
                            .bold()
                        
                        Text("- Built with SwiftUI and Xcode")
                        Text("- Audio handled using AVFoundation")
                        Text("- Story content inspired by Indonesian folklore")
                    }
                    
                    // Assets and Tools
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Assets and Tools")
                            .font(.title2)
                            .bold()
                        
                        Text("- Images generated using **Leonardo.AI**")
                        Text("- 3D models created with **Meshy.AI**")
                        Text("- Dialog audio generated using **ElevenLabs**")
                    }
                    
                    // Audio Credits
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Audio Credits")
                            .font(.title2)
                            .bold()
                        
                        Text("- Background music: [YouTube Link](https://youtu.be/q-gp58dQiSQ?si=yVzF-GJpONWplBRP)")
                        Text("- Clock sound effect: [YouTube Link](https://youtu.be/J0sTjeK92gI?si=8Qt2sxqktBGTPej_)")
                        Text("- Lose sound effect: [YouTube Link](https://youtu.be/CQeezCdF4mk?si=TZeaSmHIGCmr66YY)")
                        Text("- Winning sound effect: [YouTube Link](https://youtu.be/rr5CMS2GtCY?si=8hZ9Z_aEPeH5bMP6)")
                    }
                    
                    // Special Thanks
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
            
            // Close Button
            Button(action: {
                dismiss()
            }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
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
