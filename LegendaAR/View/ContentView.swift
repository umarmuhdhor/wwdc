import SwiftUI

struct ContentView: View {
    let stories: [Story] = [SangkuriangStory]
    
    @State private var showOpeningView = false
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Legend of the Archipelago")
                        .font(.title)
                        .bold()

                    Spacer()

                    Button(action: {
                        // Fungsi tombol + (akan diisi nanti)
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Daftar Cerita
                List(stories) { story in
                    Button(action: {
                        showOpeningView = true
                    }) {
                        HStack {
                            // Gambar Cerita
                            Image(story.backgroundImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                                .clipped() // Memastikan gambar tidak melampaui batas

                            // Judul Cerita
                            Text(story.title)
                                .font(.title2)
                                .bold()
                                .padding(.leading, 10)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle()) // Menghilangkan gaya default List
            }
            .padding(.top, 10) // Memberikan ruang agar tampilan lebih rapi
        }
        .fullScreenCover(isPresented: $showOpeningView) {
            OpeningView(showOpeningView: $showOpeningView) // Kirim binding ke OpeningView
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
