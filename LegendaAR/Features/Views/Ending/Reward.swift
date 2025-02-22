import SwiftUI

struct Reward: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

struct RewardsView: View {
    @Binding var isPresented: Bool
    
    let rewards: [Reward] = [
        Reward(title: "Sundanese Traditional Outfit", description: "The elegant attire worn by Dayang Sumbi and Sangkuriang.", imageName: "background_narasi1"),
        Reward(title: "Sundanese Song", description: "A beautiful traditional Sundanese melody.", imageName: "background_narasi1"),
        Reward(title: "Tangkuban Perahu Mountain", description: "The legendary mountain formed by Sangkuriang's fury.", imageName: "background_narasi1"),
        Reward(title: "Kujang Dagger", description: "A symbol of bravery in Sundanese culture.", imageName: "background_narasi1"),
        Reward(title: "Citarum River Legend", description: "The great river linked to the story's challenge.", imageName: "background_narasi1"),
        Reward(title: "Tumang the Mystical Dog", description: "Sangkuriang's loyal companion, who was actually his father.", imageName: "background_narasi1"),
        Reward(title: "Moral of the Story", description: "A lesson on patience, sincerity, and destiny.", imageName: "background_narasi1")
    ]
    
    private let columns = [GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)]
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView(
                    backAction: {
                        isPresented = false
                    }
                )
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(rewards) { reward in
                            RewardCard(reward: reward)
                                .transition(.scale)
                                .scaleEffect(isAnimating ? 1 : 0.9)
                                .opacity(isAnimating ? 1 : 0)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.6)
                                    .delay(Double(rewards.firstIndex(where: { $0.id == reward.id }) ?? 0) * 0.1),
                                    value: isAnimating
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

struct HeaderView: View {
    var backAction: () -> Void
    
    var body: some View {
        HStack {
            Text("Achievements")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .shadow(radius: 5)
                .padding(.leading, 20)
            
            Spacer()
            
            Button(action: backAction) {
                HStack {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                    Text("Back to Story")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.trailing, 20)
            }
        }
        .padding(.vertical, 20)
    }
}

struct RewardCard: View {
    let reward: Reward
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RewardImageView(imageName: reward.imageName)
            RewardTextView(title: reward.title, description: reward.description)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue.opacity(0.3))
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct RewardImageView: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
            )
    }
}

struct RewardTextView: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(radius: 3)
                .lineLimit(2)
            
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(3)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Achievement Unlocked")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
            }
            .padding(.top, 5)
        }
        .padding(.horizontal, 15)
        .padding(.bottom, 15)
    }
}
