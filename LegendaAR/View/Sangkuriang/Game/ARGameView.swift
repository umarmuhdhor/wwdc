import SwiftUI
import RealityKit

struct ARGameView: View {
    @State private var isARViewPresented = true
    @State private var showChoiceDialog = false
    @State private var gameResult: GameResult?
    
    @StateObject private var audioManager = AudioPlayerManager()
    @Binding var showGameView: Bool
    
    var body: some View {
        ZStack {
            // Main AR Content
            ARGameViewContainer(
                showChoiceDialog: $showChoiceDialog,
                gameResult: $gameResult,
                audioManager: audioManager
            )
            .edgesIgnoringSafeArea(.all)
            
            // Top close button
            VStack {
                HStack {
                    Spacer()
                    CloseButton(isPresented: $showGameView)
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                        .onTapGesture {
                            audioManager.stopAudio()
                            showGameView = false
                        }
                }
                Spacer()
            }
            
            // Choice Dialog
            if showChoiceDialog {
                VStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Text("What will you do?")
                            .font(.headline)
                            .padding(.top)
                        
                        Button(action: {
                            // Hand over Tumang's heart
                            showChoiceDialog = false
                            audioManager.playAudio(filename: "HeartDecision")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showGameView = false
                                // Here you would trigger the transition to the next scene
                            }
                        }) {
                            Text("Hand over Tumang's heart")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showChoiceDialog = false
                            // Reset the AR scene
                            isARViewPresented.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isARViewPresented.toggle()
                            }
                        }) {
                            Text("Search for another animal")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
        }
        .onDisappear {
            audioManager.stopAudio()
        }
        .forceLandscape()
    }
}

struct ARGameView_Previews: PreviewProvider {
    static var previews: some View {
        ARGameView(showGameView: .constant(true))
    }
}
