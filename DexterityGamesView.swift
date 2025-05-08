//
//  DexterityGamesView.swift
//  Chiron
//
//  Created by ak on 2/22/25.
//

import SwiftUI

struct DexterityGamesView: View {
    var body: some View {
        List {
            HStack {
                Image(systemName: "pencil.tip.crop.circle")
                    .foregroundColor(Color(.systemPink))
                NavigationLink("Tracing Game") {
                    TracingGameView()
                }
                .padding()
            }
            HStack {
                Image(systemName: "hand.tap")
                    .foregroundColor(Color(.systemPink))
                NavigationLink("Dot Tapping Game") {
                    TappingGameView()
                }
                .padding()
            }
        }
        .navigationTitle("Select a Game")
    }
}

#Preview {
    DexterityGamesView()
}
