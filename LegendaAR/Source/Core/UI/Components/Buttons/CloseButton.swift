import SwiftUI

struct CloseButton: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                isPresented = false 
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}
