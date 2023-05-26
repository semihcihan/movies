//
//  PhotoCellView.swift
//  Movies
//
//  Created by Semih Cihan on 18.04.2023.
//

import SwiftUI
import Combine

struct MovieCellView: View {
    @StateObject var viewModel: ViewModel
    
    init(movie: Media?) {
        _viewModel = StateObject(wrappedValue: {
            let vm = ViewModel(movie: movie)
            vm.loadImage()
            return vm
        }())
        
    }

    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 120, height: 150)
                .opacity(0)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    LinearGradient(colors: [.white, .init(white: 0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .overlay(viewModel.image != nil ?
                         Image(uiImage: viewModel.image!)
                    .resizable()
                    .scaledToFill() : nil
                )
                .cornerRadius(8)
                .clipShape(Rectangle())
            
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.movie?.displayedTitle ?? "")
                    .font(.headline)
                Text(viewModel.movie?.overview ?? "")
                    .font(.subheadline)
                    .lineLimit(3)
            }
            .padding()
        }
        .redacted(reason: viewModel.redacted ? .placeholder : [])
        .onAppear {
            viewModel.loadImage()
        }
        .onDisappear {
            viewModel.releaseImage()
        }
    }
}

extension MovieCellView {
    class ViewModel: ObservableObject {
        @Published var image: UIImage?
        var error: ImageError?
        var movie: Media?
        var cancellable: Cancellable?
        var imageService: ImageService
        var redacted: Bool
        
        init(movie: Media? = nil, imageService: ImageService = DIContainer.shared.resolve(type: ImageService.self)) {
            self.movie = movie ?? Media.preview
            self.imageService = imageService
            self.redacted = movie == nil
        }
        
        enum ImageError: String, Error {
            case badURL = "Bad URL"
            case loadError = "Something went wrong while loading"
        }
        
        func loadImage() {
            var posterPath: String?
            var size: String?
            if movie?.posterPath != nil {
                posterPath = movie?.posterPath
                size = MovieImageSize.PosterSize.w185.rawValue
            } else if movie?.backdropPath != nil {
                posterPath = movie?.backdropPath
                size = MovieImageSize.BackdropSize.w300.rawValue
            } else {
                posterPath = movie?.profilePath
                size = MovieImageSize.ProfileSize.w185.rawValue
            }
            
            guard let path = posterPath, let size = size else {
                self.error = ImageError.badURL
                return
            }
            
            self.cancellable = imageService.loadImage(
                ImagePath.path(path: path, size: size)
            )
                .sink { [weak self] _ in
                    self?.error = ImageError.loadError
                } receiveValue: { [weak self] data in
                    guard let image = UIImage(data: data) else {
                        self?.error = ImageError.loadError
                        return
                    }
                    self?.image = image
                    self?.error = nil
                }
        }
        
        func releaseImage() {
            cancellable = nil
            image = nil
            error = nil
        }
    }
}


struct MovieCellView_Previews: PreviewProvider {
    static var previews: some View {
        MovieCellView(movie: Media.preview)
    }
}
