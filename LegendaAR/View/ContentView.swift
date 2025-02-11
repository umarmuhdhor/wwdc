import SwiftUI

struct ContentView: View {
    let stories: [Story] = [earlyStory] // Perbaikan agar konsisten dengan StoryListView

    var body: some View {
        NavigationView {
            VStack {
                Text("Legend of the Archipelago") // Full English version
                    .font(.largeTitle)
                    .bold()
                    .padding()

                List(stories) { story in
                    NavigationLink(destination: StoryDetailView(story: story)) {
                        HStack {
                            Image(story.backgroundImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                            Text(story.title)
                                .font(.title2)
                                .bold()
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Sangkuriang Story")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
