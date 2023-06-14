import SwiftUI

struct mylist: View {
    class ResData: ObservableObject {
        @Published var content: [Element] = []
    }
    
    @StateObject var resData = ResData()
    @State var isChecked :Bool = false
    
    struct Element: Identifiable, Decodable {
        var id: Int
        var chordProgression: String
        var mood: String
        var checked: Bool
    }
    
    struct DeleteElement: Codable {
        var chordProgression: String
        var mood: String
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
                            // isCheckedの制御
                            let checkedArray = resData.content.filter ({ $0.checked == true })
                            if checkedArray.count > 0 {
                                isChecked = true
                            } else {
                                isChecked = false
                            }
                            
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
                //ここにremoveボタン実装
                Button(action: {
                    let content = self.resData.content
                    var deleteBody: [DeleteElement] = []
                    for item in content {
                        if item.checked {
                            let deleteElement = DeleteElement(chordProgression: item.chordProgression, mood: item.mood)
                            deleteBody.append(deleteElement)
                        }
                    }
                    print(deleteBody)
                    let encoder = JSONEncoder()
                    guard let httpBody = try? encoder.encode(deleteBody) else {return}
                    print(httpBody)
                    let url = URL(string: "https://chord-coach-server.onrender.com/api/chord-progressions")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "DELETE"
                    request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = httpBody
                    URLSession.shared.dataTask(with: request) {(data, response, error) in
                        if let error = error {
                            print("Failed to get item info: \(error)")
                            return;
                        }
                        if let response = response as? HTTPURLResponse {
                            if !(200...299).contains(response.statusCode) {
                                print("Response status code does not indicate success: \(response.statusCode)")
                                return
                            }
                        }
                        if let data = data {
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
                                    print("Chord progression removed successfully!")
                                }
                            } catch let error {
                                print(error)
                            }
                        } else {
                            print("Unexpected error.")
                        }
                    }.resume()
                    
                    
                }) {
                    Text("Remove From Favorite List")
                }
                .opacity(isChecked ? 1 : 0)
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
