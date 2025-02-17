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
        Reward(title: "Tangkuban Perahu Mountain", description: "The legendary mountain formed by Sangkuriang’s fury.", imageName: "gunung_tangkuban"),
        Reward(title: "Kujang Dagger", description: "A symbol of bravery in Sundanese culture.", imageName: "senjata_kujang"),
        Reward(title: "Citarum River Legend", description: "The great river linked to the story’s challenge.", imageName: "sungai_citarum"),
        Reward(title: "Tumang the Mystical Dog", description: "Sangkuriang’s loyal companion, who was actually his father.", imageName: "tumang"),
        Reward(title: "Moral of the Story", description: "A lesson on patience, sincerity, and destiny.", imageName: "pelajaran_moral")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Your Achievements")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                        
                    ForEach(rewards) { reward in
                        RewardCard(reward: reward)
                            .transition(.scale)
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
    }
}

struct RewardCard: View {
    let reward: Reward
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(reward.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Text(reward.title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 5)
            
            Text(reward.description)
                .font(.body)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView()
    }
}
