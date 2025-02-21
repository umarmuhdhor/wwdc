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
                // Enhanced Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(#colorLiteral(red: 0.2, green: 0.3, blue: 0.5, alpha: 1)),
                        Color(#colorLiteral(red: 0.3, green: 0.2, blue: 0.5, alpha: 1))
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Decorative Background Elements
                ForEach(0..<20) { i in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 20, height: 20)
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .opacity(isAnimating ? 0.6 : 0.2)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever()
                                .delay(Double(i) * 0.1),
                            value: isAnimating
                        )
                }
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Characters")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
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
                    
                    // Next Button
                    NextButton(title: "Begin Journey") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            z = true
                        }
                    }
                    .disabled(selectedCharacter == nil)
                    .opacity(selectedCharacter == nil ? 0.6 : 1)
                    .padding(.bottom, 40)
                }
            }
            .onAppear {
                withAnimation {
                    isAnimating = true
                }
            }
        }
        .fullScreenCover(isPresented: $z) {
            OpeningView2(showOpeningView: $z)
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
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                .scaleEffect(isSelected ? 1.05 : 1.0)
            
            // Character Info
            VStack(spacing: 8) {
                Text(name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
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
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(#colorLiteral(red: 0.3, green: 0.4, blue: 0.6, alpha: 0.8)),
                            Color(#colorLiteral(red: 0.4, green: 0.3, blue: 0.6, alpha: 0.8))
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 10)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
