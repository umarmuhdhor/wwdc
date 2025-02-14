import SwiftUI

struct ContentView: View {
    let stories: [Story] = [SangkuriangStory] 

    var body: some View {
        NavigationView {
            VStack {
                Text("Legend of the Archipelago")
                    .font(.title)
                    .bold()
                    .padding()

                List(stories) { story in
                    NavigationLink(destination: OpeningView()) {
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
