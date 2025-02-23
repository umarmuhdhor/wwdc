import SwiftUI

struct ContentView: View {
    @State private var showCharListView = false
    @State private var showCredits = false
    @State private var showStory = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.2),
                        Color.blue.opacity(0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                Circle()
                    .fill(Color.yellow.opacity(0.75))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                
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
                        showCharListView = true
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
                    .scaleEffect(showCharListView ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: showCharListView)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showStory = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "book.closed.fill")
                                    .font(.caption)
                                Text("Story")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                        .padding(.trailing, 8)
                        
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
                        .padding(.trailing)
                    }
                }
            }
        }
        .statusBar(hidden: true)
        .fullScreenCover(isPresented: $showCharListView) {
            CharacterListView(showCharListView: $showCharListView)
        }
        .sheet(isPresented: $showCredits) {
            CreditView()
        }
        .sheet(isPresented: $showStory) {
            StoryBehindView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
