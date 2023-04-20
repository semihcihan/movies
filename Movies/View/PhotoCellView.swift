//
//  PhotoCellView.swift
//  Movies
//
//  Created by Semih Cihan on 18.04.2023.
//

import SwiftUI

struct PhotoCellView: View {
    @StateObject var viewModel: PhotoCellViewModel
    
    init(photo: Photo) {
        _viewModel = StateObject(wrappedValue: { PhotoCellViewModel(photo: photo) }())
    }

    var body: some View {
        Rectangle()
            .opacity(0)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                LinearGradient(colors: [.white, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .overlay(viewModel.image != nil ?
                     Image(uiImage: viewModel.image!)
                .resizable()
                .scaledToFill() : nil
            )
            .clipShape(Rectangle())
            .onAppear {
                self.viewModel.loadImage(\.large)
            }
            .onDisappear {
                self.viewModel.releaseImage()
            }
    }
}

struct PhotoCellView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCellView(photo: Photo.preview)
    }
}
