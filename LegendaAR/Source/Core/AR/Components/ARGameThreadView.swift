import SwiftUI

struct ARThreadGameView: View {
    @ObservedObject var state: TreasureHuntState
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToNextView = false
    
    var body: some View {
        ZStack {
            ARThreadViewControllerRepresentable(state: state)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack {
                    HStack {
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                navigateToNextView = true
                            }
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .onDisappear {
            TreasureHuntState.cachedModel = nil
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.all)
        .forceLandscape()
        .fullScreenCover(isPresented: $navigateToNextView) {
            Narration1_2View(showNarrationView: $navigateToNextView)
        }
        
    }
}
