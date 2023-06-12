//
//  mylist.swift
//  swift_self_learning
//
//  Created by MatsuB on 2023/06/12.
//

import SwiftUI

struct Data: Identifiable {
    var id: Int
    var chordProgression: String
    var mood: String
    var checked: Bool
}

struct mylist: View {
    @State var chordProgressions = [
        Data(id: 1, chordProgression: "F-G-Em-Am", mood: "cool", checked: false),
        Data(id: 2, chordProgression: "D-Bm-G-A", mood: "cool", checked: false)
    ]
    
    var body: some View {
        NavigationStack {
            List(0..<chordProgressions.count, id:\.self) { index in
                Button {
                    chordProgressions[index].checked.toggle()
                } label: {
                    HStack {
                        Image(systemName: chordProgressions[index].checked ? "checkmark.circle.fill" : "circle")
                        Text(chordProgressions[index].chordProgression)
                    }
                }
                .foregroundColor(.black)
            }
        }
        .navigationTitle("Favorite List")
    }
}

struct mylist_Previews: PreviewProvider {
    static var previews: some View {
        mylist()
    }
}