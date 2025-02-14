import Foundation

struct Story: Identifiable {
    let id = UUID()
    let title: String
    let narration: String
    let characterDialogues: [CharacterDialogue]
    let audioFileName: String?
    let backgroundImage: String
}

struct CharacterDialogue: Identifiable {
    let id = UUID()
    let characterName: String
    let dialogue: String
    let audioFileName: String?
    let characterImage: String
}

let SangkuriangStory = Story(
    title: "The Beginning of Sangkuriang's Tale",
    narration: "In the land of Sunda, there lived a beautiful princess named Dayang Sumbi. One day, while weaving, her thread fell into the bushes...",
    characterDialogues: [
        CharacterDialogue(characterName: "Dayang Sumbi", dialogue: "Oh no! My weaving thread fell into the bushes!", audioFileName: "dayang_sumbi_1.mp3", characterImage: "dayang_sumbi"),
        CharacterDialogue(characterName: "Tumang", dialogue: "I will fetch it for you, my lady.", audioFileName: "tumang_1.mp3", characterImage: "tumang"),
        CharacterDialogue(characterName: "The King", dialogue: "You have deceived me, Tumang! I banish you from this palace!", audioFileName: "king_1.mp3", characterImage: "king")
    ],
    audioFileName: "opening_narration.mp3",
    backgroundImage: "background_narasi1"
)
