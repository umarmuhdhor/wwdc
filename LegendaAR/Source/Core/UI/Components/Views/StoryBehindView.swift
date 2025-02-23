import SwiftUI

struct StoryBehindView: View {
    @Environment(\.dismiss) var dismiss
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.blue.opacity(0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 30) {
                        Text("The Story Behind")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.top, 40)
                        
                        StorySection(
                            title: "A Family Gathering",
                            content: "The idea for this game came to me during a big family gathering. Many of my younger cousins—yeah, Gen Alpha kids, haha—were there. At one point, my uncles started throwing around their classic dad jokes.",
                            iconName: "house.fill"
                        )
                        
                        StorySection(
                            title: "The Moment of Truth",
                            content: """
                            One of them asked, "Do you know why Malin Kundang was cursed into stone instead of wood or something else?"
                            
                            My little cousins replied, "Who is Malin Kundang?"
                            
                            My uncle was completely shocked and said, "You guys don't know Malin Kundang?! He's the main character in one of our traditional folktales! Look it up on YouTube!"
                            """,
                            iconName: "exclamationmark.bubble.fill"
                        )
                        
                        StorySection(
                            title: "The Response",
                            content: "To which my cousins responded, \"Nah, we don't wanna watch those old, boring story videos.\"",
                            iconName: "person.2.fill"
                        )
                        
                        StorySection(
                            title: "The Realization",
                            content: "That moment hit me hard. Malin Kundang is one of the most well-known legends in Indonesian folklore, telling the story of a young man who was cursed into stone for disowning his mother. If kids today have already forgotten a story as iconic as his, what about other legends?",
                            iconName: "lightbulb.fill"
                        )
                        
                        StorySection(
                            title: "The Solution",
                            content: "I didn't want that to happen. So, I created LegendAR game that brings these stories to life in a way that's fun, interactive, and immersive. Instead of just being words in a history book, these legends can be experienced—felt, played, and lived—ensuring they stay alive for generations to come.",
                            iconName: "sparkles"
                        )
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct StorySection: View {
    let title: String
    let content: String
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text(content)
                .font(.body)
                .lineSpacing(8)
                .opacity(0.8)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 10)
        )
    }
}
