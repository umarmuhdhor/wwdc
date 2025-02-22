import SwiftUI

struct ShipPuzzleGameView: View {
    @StateObject private var arViewModel = ARViewModel()
    @State private var showSuccess = false
    @State private var showInstructions = true
    @Binding var showPuzzleView: Bool
    
    var body: some View {
        ZStack {
            ARViewContainer(arViewModel: arViewModel)
                .edgesIgnoringSafeArea(.all)
            
            if arViewModel.scanningFloor {
                ScanningOverlayView()
            }
            
            VStack {
                HStack {
                    Button(action: { showPuzzleView = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: { arViewModel.resetGame() }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Text("Parts: \(arViewModel.placedParts)/\(arViewModel.totalParts)")
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
                
                if !showSuccess {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(arViewModel.availableParts) { part in
                                ShipPartButton(part: part) {
                                    arViewModel.selectPart(part)
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                    }
                }
            }
            
            if showInstructions {
                EnhancedInstructionsView {
                    showInstructions = false
                }
            }
            
            if showSuccess {
                SuccessView {
                    arViewModel.resetGame()
                }
            }
        }
        .onChange(of: arViewModel.placedParts) { newValue in
            if newValue == arViewModel.totalParts {
                showSuccess = true
            }
        }
    }
}
