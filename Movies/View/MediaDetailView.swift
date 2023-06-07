//
//  PhotoView.swift
//  Movies
//
//  Created by Semih Cihan on 20.04.2023.
//

import SwiftUI
import Combine

struct MediaDetailView: View {
    @StateObject private var viewModel: ViewModel
    @State private var heartScale = 1.0
    @State private var imageScale = 1.0
    
    @State private var magnificationPrevValue = 1.0
    @State private var translationPrevValue: CGSize = .zero
    @State private var imageOffset: CGSize = .zero
        
    let animationDuration = 0.2
        
    init(
        media: Media?,
        imageService: ImageService = DIContainer.shared.resolve(type: ImageService.self),
        genreService: GenreService = DIContainer.shared.resolve(type: GenreService.self)
    ) {
        _viewModel = StateObject(wrappedValue: {
            let vm = ViewModel(media: media)
            vm.genreService = genreService
            vm.imageService = imageService
            return vm
        }())
    }

    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    if let image = viewModel.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(CGSize(width: 500, height: 281), contentMode: .fit)
                        
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
                            withAnimation(.easeInOut(duration: animationDuration)) {
                                heartScale = 1.2
                            }

                            withAnimation(.easeInOut(duration: animationDuration).delay(animationDuration)) {
                                heartScale = 1
                            }
                        },
                    alignment: .bottomTrailing
                )
                                
                ScrollView(.horizontal) {
                    LazyHStack {
                        Divider()
                            .frame(height: 12)
                        ForEach(viewModel.genres) { genre in
                            Text(genre.name.uppercased())
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Divider()
                                .frame(height: 12)
                        }
                    }
                }
                .offset(.init(width: 20, height: 4))
                .scrollIndicators(.hidden)

                
                VStack(spacing: 12) {
                    Text(viewModel.media?.displayedName ?? "")
                        .font(.largeTitle)
                    Text(viewModel.media?.overview ?? "")
                }
                .padding(20)
                
                Spacer()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.load()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

extension MediaDetailView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var image: UIImage?
        @Published var genres: [Genre] = []
        var error: ImageError?
        var media: Media?
        var imageService: ImageService
        var genreService: GenreService

        init(
            media: Media? = nil,
            imageService: ImageService = DIContainer.shared.resolve(type: ImageService.self),
            genreService: GenreService = DIContainer.shared.resolve(type: GenreService.self)
        ) {
            self.media = media ?? Media.movie(.preview)
            self.imageService = imageService
            self.genreService = genreService
        }
        
        enum ImageError: String, Error {
            case badURL = "Bad URL"
            case loadError = "Something went wrong while loading"
        }
        
        func load() {
            Task {
                await loadImage()
            }
            
            Task {
                await loadGenres()
            }
        }
        
        func loadGenres() async {
            guard let media = media else {
                return
            }
            
            var mediaGenreIds: [Int] = []
            switch media {
                case .movie(let movie):
                    mediaGenreIds = movie.genreIds
                case .tv(let tv):
                    mediaGenreIds = tv.genreIds
                case .person(_):
                    return
            }
            
            self.genres = (try? await genreService.genres(id: mediaGenreIds)) ?? []
        }
        
        func loadImage() async {
            var path: String?
            var size: String?
            
            guard let media = media else {
                self.error = ImageError.badURL
                return
            }
            
            switch media {
                case .movie(let movie):
                    path = movie.backdropPath
                    size = MovieImageSize.PosterSize.w500.rawValue
                case .tv(let tv):
                    path = tv.backdropPath
                    size = MovieImageSize.PosterSize.w500.rawValue
                case .person(let person):
                    path = person.profilePath
                    size = MovieImageSize.ProfileSize.w185.rawValue
            }
            
            guard let path = path, let size = size else {
                self.error = ImageError.badURL
                return
            }
            
            do {
                let data = try await imageService.loadImage(ImagePath.path(path: path, size: size))
                guard let imageFromData = UIImage(data: data) else {
                    throw ImageError.loadError
                }
                image = imageFromData
                error = nil
            } catch {
                self.error = ImageError.loadError
            }
        }
        
        func cleanup() {
            self.image = nil
            self.error = nil
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MediaDetailView(media: Media.movie(Movie.preview), genreService: PreviewGenreService())
    }
}
