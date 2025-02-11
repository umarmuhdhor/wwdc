import SwiftUI

struct ContentView: View {
    let stories = [
        Story(id: 1, title: "Sangkuriang", imageName: "sangkuriang_thumbnail")
    ]

    var body: some View {
        NavigationView {
            VStack {
                Text("Legenda Nusantara")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                List(stories) { story in
                    NavigationLink(destination: StoryDetailView(story: story)) {
                        HStack {
                            Image(story.imageName)
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
