import SwiftUI

struct StoryListView: View {
    var body: some View {
        NavigationView {
            List(stories) { story in
                NavigationLink(destination: StoryDetailView(story: story)) {
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
