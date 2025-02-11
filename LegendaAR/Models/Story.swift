import Foundation

struct Story: Identifiable {
    let id = UUID()
    let title: String
    let narration: String
    let characterDialogues: [CharacterDialogue]
    let interactiveElement: InteractiveElement?
    let audioFileName: String? // Nama file MP3 untuk narasi
}

struct CharacterDialogue: Identifiable {
    let id = UUID()
    let characterName: String
    let dialogue: String
    let audioFileName: String? // Nama file MP3 untuk dialog karakter
}

struct InteractiveElement {
    let type: InteractionType
    let description: String
}

enum InteractionType {
    case tapToContinue
    case arHuntingGame
    case puzzleChallenge
    case shakeToReact
}

// Data Dummy
let stories: [Story] = [
    Story(
        title: "Prologue",
        narration: "Long ago, in the lush lands of Sunda, there lived a beautiful princess named Dayang Sumbi...",
        characterDialogues: [
            CharacterDialogue(characterName: "Dayang Sumbi", dialogue: "Oh no! My thread has fallen into the bushes!", audioFileName: "dayang_sumbi_1.mp3"),
            CharacterDialogue(characterName: "Tumang", dialogue: "Princess, here is your thread.", audioFileName: "tumang_1.mp3")
        ],
        interactiveElement: InteractiveElement(type: .tapToContinue, description: "Tap to continue the story."),
        audioFileName: "prologue_narration.mp3"
    )
]
