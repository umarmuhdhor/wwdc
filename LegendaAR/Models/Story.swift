import Foundation

struct Story: Identifiable {
    let id = UUID()
    let title: String
    let backgroundImage: String
    let isDisabled: Bool
}

let SangkuriangStory = Story(
    title: "The Beginning of Sangkuriang's Tale",
    backgroundImage: "background_narasi1",
    isDisabled: false
)

let DummyStory1 = Story(
    title: "Coming Soon",
    backgroundImage: "background_narasi1",
    isDisabled: true
)

let DummyStory2 = Story(
    title: "Coming Soon",
    backgroundImage: "background_narasi1",
    isDisabled: true
)
