import SwiftUI

struct ContentView: View {
    @State var mood = ""
//    @State var chordProgressions: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // インプットボックス
                TextField("Input the mood of song you want to compose", text: $mood)
                
                // ボタン作成
                Button(action: {
                    // クリック時の動作
                    // moodに値が入っていたら
//                    if let encodedMood = mood.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//                        // urlがnilじゃなければ
//                        if let url = URL(string: "https://chord-coach-server.onrender.com/api/chord-progressions/?mood=\(encodedMood)") {
//                            // リクエスト生成
//                            var request = URLRequest(url: url)
//                            //非同期で通信を行う
//                            URLSession.shared.dataTask(with: request) { data, response, error in
//                                // エラーが返ってきた時の処理
//                                if let error = error {
//                                    print("Error: \(error)")
//                                } else if let data = data {
//                                    if let chordProgressions = try? JSONDecoder().decode([String].self, from: data) {
////                                        self.chordProgressions = chordProgressions
//                                        print(chordProgressions)
//                                    }
//                                }
//                            }.resume()
//                        }
//                    }
                }) {
                    Text("Button")
                }
                
//                List(chordProgressions, id: \.self) { chordProgression in
//                    Text(chordProgression)
//                }
                NavigationLink {
                    mylist()
                } label: {
                    Text("Favorite List")
                }

            }
            .navigationTitle("Suggestion")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
