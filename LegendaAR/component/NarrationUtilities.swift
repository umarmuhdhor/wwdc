import SwiftUI
import AVFoundation

// MARK: - Audio Manager
class AudioPlayerManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    
    func playAudio(filename: String) {
        if let path = Bundle.main.path(forResource: filename, ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            } catch {
                print("Error playing audio: \(error.localizedDescription)")
            }
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
    }
}

struct TextAnimation {
    static func animateText(
        text: String,
        displayedText: Binding<String>,
        speed: Double = 0.05,
        completion: @escaping () -> Void
    ) -> Timer {
        var index = 0
        displayedText.wrappedValue = "" // Reset text at start
        
        let timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { timer in
            if index < text.count {
                let character = text[text.index(text.startIndex, offsetBy: index)]
                displayedText.wrappedValue.append(character)
                index += 1
            } else {
                timer.invalidate()
                completion()
            }
        }
        
        return timer
    }
}

// MARK: - Dialogue Utilities
struct DialogueManager {
    static func playDialogue(
        text: String,
        audio: String,
        audioManager: AudioPlayerManager,
        displayedText: Binding<String>,
        isTextVisible: Binding<Bool>,
        completion: @escaping () -> Void
    ) {
        audioManager.playAudio(filename: audio)
        isTextVisible.wrappedValue = true
        displayedText.wrappedValue = ""
        
        TextAnimation.animateText(text: text, displayedText: displayedText) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isTextVisible.wrappedValue = false
                completion()
            }
        }
    }
}

struct DialogueTextView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.body)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .padding()
            .background(Color.white.opacity(0.6))
            .cornerRadius(10)
    }
}
