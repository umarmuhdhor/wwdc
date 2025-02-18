import SwiftUI


struct ContentView: View {
    let stories: [Story] = [SangkuriangStory, DummyStory1, DummyStory2]
    
    @State private var showOpeningView = false
    @State private var showCredits = false // State untuk menampilkan CreditView
    
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
                
                List(stories) { story in
                    Button(action: {
                        if !story.isDisabled {
                            showOpeningView = true
                        }
                    }) {
                        HStack {
                            Image(story.backgroundImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                                .clipped()
                                .opacity(story.isDisabled ? 0.5 : 1)
                            
                            Text(story.title)
                                .font(.title2)
                                .bold()
                                .padding(.leading, 10)
                                .opacity(story.isDisabled ? 0.5 : 1)
                        }
                        .padding(.vertical, 8)
                    }
                    .disabled(story.isDisabled)
                }
                .listStyle(PlainListStyle())
            }
            .padding(.top, 10)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    showCredits = true
                }) {
                    Text("Credits")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $showOpeningView) {
            OpeningView(showOpeningView: $showOpeningView)
        }
        .sheet(isPresented: $showCredits) {
            CreditView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
