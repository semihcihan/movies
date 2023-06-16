//
//  ContentView.swift
//  Movies
//
//  Created by Semih Cihan on 17.04.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ListView(viewModel: ListView.ViewModel())            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
