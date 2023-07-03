//
//  InfoView.swift
//  Movies
//
//  Created by Semih Cihan on 3.07.2023.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image("moviedb")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .frame(height: 100)
            Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 40)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
