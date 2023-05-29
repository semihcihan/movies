//
//  PhotoView.swift
//  Movies
//
//  Created by Semih Cihan on 20.04.2023.
//

import SwiftUI
import Combine

struct MovieDetailView: View {
    @StateObject private var viewModel: ViewModel
    @State private var heartScale = 1.0
    @State private var imageScale = 1.0
    
    @State private var magnificationPrevValue = 1.0
    @State private var translationPrevValue: CGSize = .zero
    @State private var imageOffset: CGSize = .zero
        
    let animationDuration = 0.2
        
    init(media: Media?) {
        _viewModel = StateObject(wrappedValue: { ViewModel(media: media) }())
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    if let image = viewModel.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Color.white
                            .frame(height: 220)
                    }
                }
                .overlay(
                    Image(systemName: "heart")
                        .font(.largeTitle)
                        .scaleEffect(heartScale)
                        .foregroundColor(.pink)                        
                        .padding()
                        .onTapGesture {
                            withAnimation(Animation.easeInOut(duration: animationDuration)) {
                                heartScale = 1.2
                            }

                            withAnimation(Animation.easeInOut(duration: animationDuration).delay(animationDuration)) {
                                heartScale = 1
                            }
                        },
                    alignment: .bottomLeading
                )
                
                VStack(spacing: 8) {
                    Text(viewModel.media?.displayedName ?? "")
                        .font(.largeTitle)
                    Text(viewModel.media?.overview ?? "")
                }
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.loadImage()
        }
        .onDisappear {
            viewModel.releaseImage()
        }
    }
}

extension MovieDetailView {
    class ViewModel: ObservableObject {
        @Published var image: UIImage?
        var error: ImageError?
        var media: Media?
        var cancellable: Cancellable?
        var imageService: ImageService        

        init(media: Media? = nil, imageService: ImageService = DIContainer.shared.resolve(type: ImageService.self)) {
            self.media = media ?? Media.movie(.preview)
            self.imageService = imageService
        }
        
        enum ImageError: String, Error {
            case badURL = "Bad URL"
            case loadError = "Something went wrong while loading"
        }
        
        func loadImage() {
            var path: String?
            var size: String?
            
            guard let media = media else {
                self.error = ImageError.badURL
                return
            }
            
            switch media {
                case .movie(let movie):
                    path = movie.backdropPath
                    size = MovieImageSize.PosterSize.w185.rawValue
                case .tv(let tv):
                    path = tv.backdropPath
                    size = MovieImageSize.PosterSize.w185.rawValue
                case .person(let person):
                    path = person.profilePath
                    size = MovieImageSize.ProfileSize.w185.rawValue
            }
            
            guard let path = path, let size = size else {
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
            self.cancellable = nil
            self.image = nil
            self.error = nil
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(media: Media.movie(.preview))
    }
}
