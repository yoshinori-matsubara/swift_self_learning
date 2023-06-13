import SwiftUI

struct mylist: View {
    class ResData: ObservableObject {
        @Published var content: [Element] = []
    }
    
    @StateObject var resData = ResData()
    
    struct Element: Identifiable, Decodable {
        var id: Int
        var chordProgression: String
        var mood: String
        var checked: Bool
    }
    
    struct res {
        var role: String
        var content: [Element]
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if !resData.content.isEmpty {
                    List(resData.content.indices, id: \.self) { index in
                        Button(action: {
                            resData.content[index].checked.toggle()
                            print(resData.content[index].checked)
                        }) {
                            HStack {
                                Image(systemName: resData.content[index].checked ? "checkmark.circle.fill" : "circle")
                                Text(resData.content[index].chordProgression)
                                Text(resData.content[index].mood)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                let url = URL(string: "https://chord-coach-server.onrender.com/api/my-chord-progressions")!
                var request = URLRequest(url: url)
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data else { return }
                    
                    do {
                        let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                        if let jsonArray = jsonArray {
                            var elements: [Element] = []
                            for data in jsonArray {
                                if let id = data["id"] as? Int,
                                   let chordProgression = data["chord_progression"] as? String,
                                   let mood = data["mood"] as? String {
                                    let elementData = Element(id: id, chordProgression: chordProgression, mood: mood, checked: false)
                                    elements.append(elementData)
                                }
                            }
                            DispatchQueue.main.async {
                                self.resData.content = elements
                            }
                        }
                    } catch let error {
                        print(error)
                    }
                }.resume()
            }
            .navigationTitle("Favorite List")
        }
    }
}

struct mylist_Previews: PreviewProvider {
    static var previews: some View {
        mylist()
    }
}
