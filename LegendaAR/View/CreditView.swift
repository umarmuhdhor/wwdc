import SwiftUI

struct CreditView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Credits")
                .font(.largeTitle)
                .bold()
                .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("This app was created using:")
                        .font(.headline)
                    
                    Text("- SwiftUI")
                    Text("- Xcode")
                    Text("- AVFoundation for Audio")
                    Text("- Custom Assets and Illustrations")
                    Text("- Story Content inspired by Indonesian folklore")
                    
                    Text("Special Thanks:")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    Text("- Open Source Libraries")
                    Text("- Community Contributors")
                    Text("- Beta Testers")
                }
                .padding()
            }
            
            Button("Close") {
                dismiss()
            }
            .padding()
        }
    }
}
