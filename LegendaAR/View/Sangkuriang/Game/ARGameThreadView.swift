import SwiftUI

struct ARThreadGameView: View {
    @ObservedObject var state: TreasureHuntState
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToNextView = false
    
    var body: some View {
        ZStack {
            // AR View takes full screen
            ARThreadViewControllerRepresentable(state: state)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            
            // Overlay content
            GeometryReader { geometry in
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
                            state.scale += 0.1
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
                        Text("Threads: \(state.foundCount)/\(state.totalCount)")
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
                    .padding(.top, geometry.safeAreaInsets.top + 10)
                    
                    Spacer()
                    
                    // Instructions or Completion Message
                    if state.foundCount < state.totalCount {
                        Text("Tap to find the threads!")
                            .font(.headline)
                            .fontWeight(.medium)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                            .transition(.opacity)
                            .animation(.easeInOut, value: state.foundCount)
                    } else {
                        VStack {
                            Text("🎉 All threads found! 🎉")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.green.opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                .padding(.bottom, 10)
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                        .transition(.opacity)
                        .animation(.easeInOut, value: state.foundCount)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                navigateToNextView = true
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.all)
        .forceLandscape()
        .background(
            NavigationLink(destination: Narration1_2View(showNarrationView: $navigateToNextView), isActive: $navigateToNextView) {
                EmptyView()
            }
            .hidden()
        )
    }
}
