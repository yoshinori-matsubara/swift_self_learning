import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView("Now Loading")
    }
}

struct ContentView: View {
    @State var mood = ""
    @State var resData: ContentView.res? = nil
    @State var isChecked: Bool = false
    @State var isLoading: Bool = false
    
    struct Element: Identifiable {
        var id: Int
        var chordProgression: String
        var checked: Bool
    }
    
    struct PostElement: Codable {
        var chordProgressions: [String]
        var mood: String
    }
    
    struct res {
        var role: String
        var content: [Element]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    TextField("Input the mood of the song you want to compose", text: $mood)
                    
                    Button(action: {
                        isLoading = true
                        
                        if let encodedMood = mood.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                            if let url = URL(string: "https://chord-coach-server.onrender.com/api/chord-progressions/?mood=\(encodedMood)") {
                                let request = URLRequest(url: url)
                                
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
                                    
                                    DispatchQueue.main.async {
                                        isLoading = false
                                    }
                                }.resume()
                            }
                        } else {
                            isLoading = false
                        }
                    }) {
                        Text("Suggest")
                    }
                    
                    ListView(resData: self.$resData, isChecked: self.$isChecked)
                    
                    Button(action: {
                        if let content = self.resData?.content {
                            var chordProgressions: [String] = []
                            
                            for item in content {
                                if item.checked {
                                    chordProgressions.append(item.chordProgression)
                                }
                            }
                            
                            let postData = PostElement(chordProgressions: chordProgressions, mood: self.mood)
                            let encoder = JSONEncoder()
                            
                            guard let httpBody = try? encoder.encode(postData) else { return }
                            
                            let url = URL(string: "https://chord-coach-server.onrender.com/api/chord-progressions")!
                            var request = URLRequest(url: url)
                            
                            request.httpMethod = "POST"
                            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
                            request.httpBody = httpBody
                            
                            URLSession.shared.dataTask(with: request) { (data, response, error) in
                                if let error = error {
                                    print("Failed to get item info: \(error)")
                                    return
                                }
                                
                                if let response = response as? HTTPURLResponse {
                                    if !(200...299).contains(response.statusCode) {
                                        print("Response status code does not indicate success: \(response.statusCode)")
                                        return
                                    }
                                }
                                
                                if let data = data {
                                    print("Chord progression saved successfully!")
                                } else {
                                    print("Unexpected error.")
                                }
                            }.resume()
                        }
                    }) {
                        Text("Add to Favorite List")
                    }
                    .opacity(isChecked ? 1 : 0)
                    
                    NavigationLink(destination: mylist()) {
                        Text("Go to Favorite List")
                    }
                }
                
                if isLoading {
                    LoadingView()
                        .opacity(1)
                }
            }
            .navigationTitle("Suggestion")
        }
    }
}

struct ListView: View {
    @Binding var resData: ContentView.res?
    @Binding var isChecked: Bool
    
    var body: some View {
        NavigationView {
            if let resData = resData {
                List(resData.content.indices, id: \.self) { index in
                    let element = resData.content[index]
                    
                    Button(action: {
                        self.resData?.content[index].checked.toggle()
                        
                        if let checkedArray = self.resData?.content.filter({ $0.checked == true }) {
                            if checkedArray.count > 0 {
                                isChecked = true
                            } else {
                                isChecked = false
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: element.checked ? "checkmark.circle.fill" : "circle")
                            Text(element.chordProgression)
                        }
                    }
                }
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
