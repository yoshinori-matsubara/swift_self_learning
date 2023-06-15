import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView("Now Loading")
    }
}

struct ContentView: View {
    @State var mood = ""
    @State var resData: ContentView.Res? = nil
    @State var isChecked: Bool = false
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    
    struct Element: Identifiable, Codable {
        var id: Int
        var chordProgression: String
        var checked: Bool
    }
    
    struct PostElement: Codable {
        var chordProgressions: [String]
        var mood: String
    }
    
    struct Res: Codable {
        var role: String
        var content: [Element]
    }
    
    //    public struct ContentElement: Decodable {
    //        public var id: Int
    //        public var chordProgression: String
    //
    //        public var description: String {
    //            return "\(id) \(chordProgression)"
    //        }
    //    }
    //
    //    public struct JsonRes: Decodable, CustomStringConvertible {
    //        public var role: String
    //        public var content: [ContentElement]
    //
    //        public var description: String {
    //            return """
    //            role: \(role)
    //            content: \(content)
    //            """
    //        }
    //    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    TextField("Input the mood of the song you want to compose", text: $mood)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black.opacity(0.5), lineWidth: 1))
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
                                                        self.resData = Res(role: "assistant", content: elements)
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
                            .bold()
                            .padding()
                            .frame(width: 100, height: 50)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    .opacity(mood.count > 0 ? 1 : 0)
                    
                    ListView(resData: self.$resData, isChecked: self.$isChecked)
                    
                    Button(action: {
                        if var content = self.resData?.content {
                            var chordProgressions: [String] = []
                            
                            for index in content.indices {
                                if content[index].checked {
                                    chordProgressions.append(content[index].chordProgression)
                                    content[index].checked = false
                                }
                            }
                            isChecked = false
                            self.resData?.content = content
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
                            
                            DispatchQueue.main.async {
                                self.showAlert = true
                                
                            }
                        }
                    }) {
                        Text("Add to Favorite List")
                            .bold()
                            .padding()
                            .frame(width: 200, height: 50)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    .opacity(isChecked ? 1 : 0)
                    
                    NavigationLink(destination: MyList()) {
                        Text("Go to Favorite List")
                    }
                }
                .opacity(isLoading ? 0 : 1)
                
                LoadingView()
                    .opacity(isLoading ? 1 : 0)
                    .scaleEffect(1.5)
            }
            .navigationTitle("Suggestion")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Chord progression saved successfully!"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct ListView: View {
    @Binding var resData: ContentView.Res?
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
