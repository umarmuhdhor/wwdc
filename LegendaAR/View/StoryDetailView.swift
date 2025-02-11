import SwiftUI
import AVFoundation

struct StoryDetailView: View {
    let story: Story
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        ZStack {
            // Background Image
            Image(story.backgroundImage)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    Text(story.title)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 5)

                    // Play Narration Button
                    Button(action: {
                        playAudio(fileName: story.audioFileName)
                    }) {
                        Label("Play Narration", systemImage: "play.circle.fill")
                            .font(.title2)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Text(story.narration)
                        .font(.body)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)

                    Divider()
                    
                    // Character Dialogues
                    ForEach(story.characterDialogues) { dialogue in
                        VStack(alignment: .center, spacing: 10) {
                            Image(dialogue.characterImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)

                            Text("\(dialogue.characterName):")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text(dialogue.dialogue)
                                .font(.body)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            
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
                }
                .padding()
            }
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
        StoryDetailView(story: earlyStory)
    }
}
