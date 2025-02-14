import SwiftUI

struct ContentView: View {
    let stories: [Story] = [SangkuriangStory] // Pastikan `SangkuriangStory` adalah instance dari `Story`

    var body: some View {
        NavigationView {
            VStack {
                // Header dengan judul dan tombol +
                HStack {
                    Text("Legend of the Archipelago")
                        .font(.title)
                        .bold()

                    Spacer() // Menekan tombol "+" ke kanan

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
                    NavigationLink(destination: OpeningView()) {
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
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
