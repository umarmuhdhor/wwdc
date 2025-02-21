import SwiftUI

struct CloseButton: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                isPresented = false // Tutup layar saat tombol diklik
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}
