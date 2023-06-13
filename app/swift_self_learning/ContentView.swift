import SwiftUI

struct ContentView: View {
    @State var mood = ""
    @State var resData: ContentView.res? = nil
    
    struct Element: Identifiable {
        var id: Int
        var chordProgression: String
        var checked: Bool
    }
    
    struct res {
        var role: String
        var content: [Element]
    }
    
    var body: some View {
        NavigationView {
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
                                                var elements: [Element] = []
                                                for data in parsedData {
                                                    if let id = data["id"] as? Int,
                                                       let chordProgression = data["chordProgression"] as? String {
                                                        let elementData = Element(id: id, chordProgression: chordProgression, checked: false)
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
                ListView(resData: self.$resData)
                NavigationLink(destination: mylist()) {
                    Text("Favorite List")
                }
            }
            .navigationTitle("Suggestion")
        }
    }
}

struct ListView: View {
    @Binding var resData: ContentView.res?
    
    var body: some View {
        NavigationView {
            if let resData = resData {
                List(resData.content.indices, id: \.self) { index in
                    let element = resData.content[index]
                    Button(action: {
                        self.resData?.content[index].checked.toggle()
                        print(self.resData?.content[index].checked ?? false)
                    }) {
                        HStack {
                            Image(systemName: element.checked ? "checkmark.circle.fill" : "circle")
                            Text(element.chordProgression)
                        }
                    }
                }
            } else {
                Text("No data")
            }
        }
        .navigationTitle("Chord Progressions")
    }
}

//struct MyListView: View {
//    var body: some View {
//        Text("Favorite List View")
//            .navigationTitle("Favorite List")
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
