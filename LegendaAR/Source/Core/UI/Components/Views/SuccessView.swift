import SwiftUI

struct SuccessView: View {
    let dismissAction: () -> Void
    @State private var navigateNextView = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
            
            VStack(spacing: 20) {
                Text("Congratulations!")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("You've successfully built the ship!")
                    .foregroundColor(.white)
                
                Button("Next") {
                    dismissAction()
                    navigateNextView = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $navigateNextView) {
            EndingNaration(showEndingView: $navigateNextView)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
