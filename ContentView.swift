//
//  ContentView.swift
//  Chiron
//
//  Created by ak on 2/8/25.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    
    var body: some View {
        TabView () {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }.tag(1)
            DashView()
                .tabItem {
                    Label("Dashboard", systemImage: "person.crop.circle")
                }.tag(2)
            InfoView()
                .tabItem {
                    Label("Information", systemImage: "books.vertical")
                }.tag(3)
            SupportView()
                .tabItem {
                    Label("Support", systemImage: "person.3")
                }.tag(4)
            
        }
        .accentColor(.red)
    }
}

#Preview {
    ContentView()
}
