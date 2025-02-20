import SwiftUI

struct ContentView: View {
    let stories: [Story] = [SangkuriangStory, DummyStory1, DummyStory2]
    
    @State private var showOpeningView = false
    @State private var showCredits = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                Image("background1")  
                    .edgesIgnoringSafeArea(.all)
                
                // Overlay gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.2),
                        Color.blue.opacity(0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // Sun/Moon Effect
                Circle()
                    .fill(Color.yellow.opacity(0.75))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                
                // Decorative Clouds
                ForEach([
                    (0.2, 0.15, 160, 80),
                    (0.7, 0.25, 180, 90)
                ], id: \.0) { x, y, width, height in
                    Capsule()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: width, height: height)
                        .blur(radius: 10)
                        .position(
                            x: geometry.size.width * x,
                            y: geometry.size.height * y
                        )
                }
                
                // Main Content
                VStack(spacing: 20) {
                    Text("The Legend of")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    
                    Text("SANGKURIANG")
                        .font(.system(size: 64, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    
                    Button(action: {
                        showOpeningView = true
                    }) {
                        Text("Let's Start!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.yellow)
                                    .shadow(radius: 5)
                            )
                    }
                    .scaleEffect(showOpeningView ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: showOpeningView)
                }
                
                // Credits Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showCredits = true
                        }) {
                            Text("Credits")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding()
                    }
                }
            }
        }
        .statusBar(hidden: true)
        .fullScreenCover(isPresented: $showOpeningView) {
            OpeningView(showOpeningView: $showOpeningView)
        }
        .sheet(isPresented: $showCredits) {
            CreditView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
