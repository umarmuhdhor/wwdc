import SwiftUI

struct StoryListView: View {
    let stories: [Story] = [SangkuriangStory] // Perbaikan: Dibuat array

    var body: some View {
        NavigationView {
            List(stories) { story in
                NavigationLink(destination: Narration1View()) {
                    Text(story.title)
                        .font(.headline)
                }
            }
            .navigationTitle("Sangkuriang Story")
        }
    }
}

struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        StoryListView()
    }
}
