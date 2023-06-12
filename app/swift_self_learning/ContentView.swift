import SwiftUI

struct ContentView: View {
    @State var mood = ""
    @State var resData: ContentView.res? = nil
    
    struct element {
        var id: Int
        var chordProgression: String
    }
    
    struct res {
        var role: String
        var content: [element]
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Input the mood of song you want to compose", text: $mood)
                Button(action: {
                    if let encodedMood = mood.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        if let url = URL(string: "https://chord-coach-server.onrender.com/api/chord-progressions/?mood=\(encodedMood)") {
                            var request = URLRequest(url: url)
                            URLSession.shared.dataTask(with: request) { data, response, error in
                                guard let data = data else { return }
                                do {
                                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                    if let jsonString = json?["content"] as? String {
                                        if let jsonData = jsonString.data(using: .utf8) {
                                            let parsedData = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]]
                                            
                                            if let parsedData = parsedData {
                                                var elements: [element] = []
                                                for data in parsedData {
                                                    if let id = data["id"] as? Int,
                                                       let chordProgression = data["chordProgression"] as? String {
                                                        let elementData = element(id: id, chordProgression: chordProgression)
                                                        elements.append(elementData)
                                                    }
                                                }
                                                
                                                DispatchQueue.main.async {
                                                    self.resData = res(role: "assistant", content: elements)
                                                }
                                            }
                                        }
                                    }
                                } catch let error {
                                    print(error)
                                }
                            }.resume()
                        }
                    }
                }) {
                    Text("Suggest")
                }
                ListView(resData: $resData)
                NavigationLink(destination: mylist()) {
                    Text("Favorite List")
                }
            }
        }
        .navigationTitle("Suggestion")
    }
}

struct ListView: View {
    @Binding var resData: ContentView.res?
    
    var body: some View {
        NavigationStack {
            if let resData = resData {
                List(resData.content, id: \.id) { element in
                    HStack {
                        Image(systemName: "circle")
                        Text(element.chordProgression)
                    }
                }
            } else {
                Text("No data")
            }
        }
        .navigationTitle("Chord Progressions")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
