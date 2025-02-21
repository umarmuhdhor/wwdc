import SwiftUI

struct CharacterListView: View {
    @Binding var showCharListView: Bool
    @State private var z = false
    @State private var selectedCharacter: String?
    @State private var isAnimating = false
    
    let characters = [
        (name: "Dayang Sumbi", imageName: "dayang_sumbi", description: "A beautiful and skilled weaver, cursed to marry her own son."),
        (name: "Tumang", imageName: "tumang", description: "A divine dog who was actually a cursed god."),
        (name: "Sang Prabu", imageName: "sang_prabu", description: "The wise king who ruled the kingdom."),
        (name: "Sangkuriang", imageName: "sangkuriang", description: "The legendary hero who unknowingly fell in love with his mother.")
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Matching background gradient from opening view
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.2),
                        Color.blue.opacity(0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Sun/Moon effect from opening view
                Circle()
                    .fill(Color.yellow.opacity(0.75))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                    .position(x: geo.size.width * 0.8, y: geo.size.height * 0.2)
                
                // Decorative Clouds from opening view
                ForEach([
                    (0.2, 0.15, 160, 80),
                    (0.7, 0.25, 180, 90)
                ], id: \.0) { x, y, width, height in
                    Capsule()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: width, height: height)
                        .blur(radius: 10)
                        .position(
                            x: geo.size.width * x,
                            y: geo.size.height * y
                        )
                }
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Characters")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(.leading, 30)
                        
                        Spacer()
                        
                        CloseButton(isPresented: $showCharListView)
                            .padding(.trailing, 30)
                    }
                    .padding(.top, 20)
                    
                    // Character Grid
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 25) {
                            ForEach(characters, id: \.name) { character in
                                CharacterCard(
                                    name: character.name,
                                    imageName: character.imageName,
                                    description: character.description,
                                    isSelected: selectedCharacter == character.name
                                )
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedCharacter = character.name
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                    }
                    
                    Spacer()
                    
                    // Next Button - matching opening view style
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            z = true
                        }
                    }) {
                        Text("Begin Journey")
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
                    .disabled(selectedCharacter == nil)
                    .opacity(selectedCharacter == nil ? 0.6 : 1)
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $z) {
            EndingNaration(showOpeningView: $z)
        }
    }
}

struct CharacterCard: View {
    let name: String
    let imageName: String
    let description: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Character Image
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                .scaleEffect(isSelected ? 1.05 : 1.0)
            
            // Character Info
            VStack(spacing: 8) {
                Text(name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .frame(width: 200)
                    .lineLimit(3)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.blue.opacity(0.3))
                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 10)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
