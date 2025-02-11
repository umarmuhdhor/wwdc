import SwiftUI
import AVFoundation

struct StoryDetailView: View {
    let story: Story
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack {
            Image(story.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .cornerRadius(10)
                .padding()

            Text(story.title)
                .font(.largeTitle)
                .bold()

            Button(action: playNarration) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                    Text("Dengarkan Narasi")
                        .font(.title2)
                        .bold()
                }
                .padding()
            }
            
            Spacer()
            
            NavigationLink(destination: ARViewContainer()) {
                Text("Masuk ke AR")
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            prepareAudio()
        }
    }

    func prepareAudio() {
        if let path = Bundle.main.path(forResource: "sangkuriang_audio", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("❌ Gagal memuat audio: \(error)")
            }
        }
    }

    func playNarration() {
        audioPlayer?.play()
    }
}

struct StoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StoryDetailView(story: Story(id: 1, title: "Sangkuriang", imageName: "sangkuriang_thumbnail"))
    }
}
