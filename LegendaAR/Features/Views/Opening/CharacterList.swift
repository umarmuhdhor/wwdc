import SwiftUI

struct CharacterListView: View {
    @Binding var showCharListView: Bool
    @State private var z = false
    @State private var selectedCharacter: String?
    @State private var isAnimating = false
    
    let characters = [
        (name: "Dayang Sumbi", imageName: "DayangSumbi", description: "A beautiful and skilled weaver, cursed to unknowingly fall in love with her own son."),
        (name: "Sang Prabu", imageName: "SangPrabu", description: "A wise and just king who ruled the kingdom."),
        (name: "Sangkuriang", imageName: "Sangkuriang", description: "A legendary warrior who unknowingly fell in love with his own mother."),
        (name: "Sangkuriang (Child)", imageName: "Sangkuriang_Child", description: "The young version of Sangkuriang, unaware of his tragic destiny."),
        (name: "Tumang", imageName: "Tumang", description: "A loyal royal servant who was destined to be with Dayang Sumbi."),
        (name: "Tumang (Dog)", imageName: "Tumang_Dog", description: "Tumang, who was cursed to live as a dog.")
    ]

    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.2),
                        Color.blue.opacity(0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                Circle()
                    .fill(Color.yellow.opacity(0.75))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                    .position(x: geo.size.width * 0.8, y: geo.size.height * 0.2)
                
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
                    HStack {
                        Text("Characters")
                            .font(.system(size: geo.size.width * 0.05, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(.leading, 30)
                        
                        Spacer()
                        
                        CloseButton(isPresented: $showCharListView)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                z = true
                            }
                        }) {
                            Text("Begin Journey")
                                .font(.system(size: geo.size.width * 0.02, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.vertical, geo.size.height * 0.02)
                                .padding(.horizontal, geo.size.width * 0.05) 
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.yellow)
                                        .shadow(radius: 5)
                                )
                                .padding(.trailing, 20)
                        }
                    }
                    .padding(.top, 20)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 25) {
                            ForEach(characters, id: \.name) { character in
                                VStack(spacing: 15) {
                                    Image(character.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geo.size.width * 0.25, height: geo.size.height * 0.3)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                    
                                    VStack(spacing: 8) {
                                        Text(character.name)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .shadow(radius: 3)
                                        
                                        Text(character.description)
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
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                    }
                    
                    Spacer()
                    
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $z) {
            OpeningView(showOpeningView: $z)
        }
    }
}



