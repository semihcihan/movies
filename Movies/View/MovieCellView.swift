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
    
    init(media: Media?) {
        _viewModel = StateObject(wrappedValue: {
            let vm = ViewModel(media: media)
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
                Text(viewModel.media?.displayedName ?? "")
                    .font(.headline)
                Text(viewModel.media?.overview ?? "")
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
        var media: Media?
        var cancellable: Cancellable?
        var imageService: ImageService
        var redacted: Bool
        
        init(media: Media? = nil, imageService: ImageService = DIContainer.shared.resolve(type: ImageService.self)) {
            self.media = media ?? .movie(Movie.preview)
            self.imageService = imageService
            self.redacted = media == nil
        }
        
        enum ImageError: String, Error {
            case badURL = "Bad URL"
            case loadError = "Something went wrong while loading"
        }
        
        func loadImage() {
            var posterPath: String?
            var size: String?
            
            guard let media = media else {
                self.error = ImageError.badURL
                return
            }
            
            switch media {
                case .movie(let movie):
                    posterPath = movie.posterPath
                    size = MovieImageSize.PosterSize.w185.rawValue
                case .tv(let tv):
                    posterPath = tv.posterPath
                    size = MovieImageSize.PosterSize.w185.rawValue
                case .person(let person):
                    posterPath = person.profilePath
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
        MovieCellView(media: Media.movie(Movie.preview))
    }
}
