//
//  ContentView.swift
//  Movies
//
//  Created by Semih Cihan on 17.04.2023.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ListView(viewModel: ListView.ViewModel(service: DIContainer.shared.resolve(type: MediaService.self)))
                .tabItem {
                    Label("Top", systemImage: "popcorn")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
