//
//  PhotoCellView.swift
//  Movies
//
//  Created by Semih Cihan on 18.04.2023.
//

import SwiftUI

struct PhotoCellView: View {
    var viewModel: PhotoCellViewModel
    
    init(photo: Photo) {
        self.viewModel = PhotoCellViewModel(photo: photo)
    }
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: viewModel.photo?.src.portrait ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 200, height: 200)
            .clipped()
            .cornerRadius(10)
            
            Text("lorem ipsum dolor sit amet very good")
                .multilineTextAlignment(.center)
                .font(.headline)
                .frame(width: 200)
        }
    }
}

struct PhotoCellView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCellView(photo: Photo.preview)
    }
}
