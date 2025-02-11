import SwiftUI
import AVFoundation

struct StoryDetailView: View {
    let story: Story
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(story.title)
                    .font(.largeTitle)
                    .bold()

                Button(action: {
                    playAudio(fileName: story.audioFileName)
                }) {
                    Label("Play Narration", systemImage: "play.circle.fill")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Text(story.narration)
                    .font(.body)

                Divider()

                ForEach(story.characterDialogues) { dialogue in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(dialogue.characterName):")
                            .font(.headline)

                        Text(dialogue.dialogue)
                            .font(.body)
                        
                        if let audioFile = dialogue.audioFileName {
                            Button(action: {
                                playAudio(fileName: audioFile)
                            }) {
                                Label("Play Dialogue", systemImage: "speaker.wave.2.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }

                if let interaction = story.interactiveElement {
                    Divider()
                    Text("Interactive Challenge:")
                        .font(.title2)
                        .bold()
                    Text(interaction.description)
                        .font(.body)
                        .padding(.bottom)
                }
            }
            .padding()
        }
    }

    func playAudio(fileName: String?) {
        guard let fileName = fileName, let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            print("Audio file not found: \(fileName ?? "Unknown")")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
}

struct StoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StoryDetailView(story: stories[0])
    }
}
