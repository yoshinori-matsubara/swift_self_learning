import SwiftUI

struct ContentView: View {
    @State var mood = ""
    @State var chordProgressions: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Input the mood of song you want to compose", text: $mood)
            Button(action: {
                if let encodedMood = mood.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    if let url = URL(string: "https://chord-coach-server.onrender.com/api/chord-progressions/?mood=\(encodedMood)") {
                        let request = URLRequest(url: url)
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            if let error = error {
                                print("Error: \(error)")
                            } else if let data = data {
                                if let chordProgressions = try? JSONDecoder().decode([String].self, from: data) {
                                    self.chordProgressions = chordProgressions
                                }
                            }
                        }.resume()
                    }
                }
            }) {
                Text("Button")
            }
            
            List(chordProgressions, id: \.self) { chordProgression in
                Text(chordProgression)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
