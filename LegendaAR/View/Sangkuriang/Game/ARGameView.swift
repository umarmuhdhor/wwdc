import SwiftUI

struct ARGameView: View {
    @ObservedObject var state: TreasureHuntState
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            ARViewControllerRepresentable(state: state)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    // Back button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // Counter display
                    Text("Benang ditemukan: \(state.foundCount)/\(state.totalCount)")
                        .font(.title2)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.trailing, 20)
                }
                .padding(.top, 44)
                
                Spacer()
                
                // Instructions
                if state.foundCount < state.totalCount {
                    Text("Ketuk untuk mencari benang!")
                        .font(.subheadline)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                } else {
                    Text("Semua benang telah ditemukan!")
                        .font(.headline)
                        .padding()
                        .background(Color.green.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
