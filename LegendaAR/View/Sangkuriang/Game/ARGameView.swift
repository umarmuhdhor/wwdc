import SwiftUI

struct ARGameView: View {
    @ObservedObject var state: TreasureHuntState
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            ARViewControllerRepresentable(state: state)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Top Bar (Back Button + Counter + Zoom Button)
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
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // Zoom button
                    Button(action: {
                        state.scale += 0.1 // Tambahkan skala
                    }) {
                        Image(systemName: "plus.magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 10)
                    
                    // Counter display
                    Text("Benang: \(state.foundCount)/\(state.totalCount)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.trailing, 20)
                }
                .padding(.top, 44)
                
                Spacer()
                
                // Instructions or Completion Message
                if state.foundCount < state.totalCount {
                    Text("Ketuk untuk mencari benang!")
                        .font(.headline)
                        .fontWeight(.medium)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.bottom, 40)
                        .transition(.opacity) // Fade animation
                        .animation(.easeInOut, value: state.foundCount)
                } else {
                    VStack {
                        Text("🎉 Semua benang telah ditemukan! 🎉")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.green.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .padding(.bottom, 10)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Kembali ke Menu")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 40)
                    .transition(.opacity) // Fade animation
                    .animation(.easeInOut, value: state.foundCount)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.black.opacity(0.001)) // Untuk memastikan tap gesture tidak terhalang
    }
}
