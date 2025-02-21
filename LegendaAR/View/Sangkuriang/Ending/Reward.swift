import SwiftUI

struct Reward: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

struct RewardsView: View {
    let rewards: [Reward] = [
        Reward(title: "Sundanese Traditional Outfit", description: "The elegant attire worn by Dayang Sumbi and Sangkuriang.", imageName: "pakaian_adat"),
        Reward(title: "Sundanese Song", description: "A beautiful traditional Sundanese melody.", imageName: "lagu_sunda"),
        Reward(title: "Tangkuban Perahu Mountain", description: "The legendary mountain formed by Sangkuriang's fury.", imageName: "gunung_tangkuban"),
        Reward(title: "Kujang Dagger", description: "A symbol of bravery in Sundanese culture.", imageName: "senjata_kujang"),
        Reward(title: "Citarum River Legend", description: "The great river linked to the story's challenge.", imageName: "sungai_citarum"),
        Reward(title: "Tumang the Mystical Dog", description: "Sangkuriang's loyal companion, who was actually his father.", imageName: "tumang"),
        Reward(title: "Moral of the Story", description: "A lesson on patience, sincerity, and destiny.", imageName: "pelajaran_moral")
    ]
    
    private let columns = [
        GridItem(.flexible(minimum: 300, maximum: 400), spacing: 20),
        GridItem(.flexible(minimum: 300, maximum: 400), spacing: 20)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    Text("Your Achievements")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, y: 5)
                    
                    // Scrollable content
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(rewards) { reward in
                            RewardCard(reward: reward)
                                .transition(.scale)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                }
                .background(Color(.systemGray6))
            }
            .navigationBarHidden(true)
        }
    }
}

struct RewardCard: View {
    let reward: Reward
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
            Image(reward.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            // Text content
            VStack(alignment: .leading, spacing: 8) {
                Text(reward.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Text(reward.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(3)
                
                Spacer()
                
                // Achievement indicator
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Unlocked")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            .padding(.vertical, 15)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView()
    }
}
