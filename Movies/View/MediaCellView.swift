//
//  PhotoCellView.swift
//  Movies
//
//  Created by Semih Cihan on 18.04.2023.
//

import SwiftUI
import Combine

struct MediaCellView: View {
    @StateObject var viewModel: ViewModel
    
    enum Size {
        case `default`
        case small
    }
    
    init(media: Media?,
         size: Size = .default,
         imageService: ImageService = DIContainer.shared.resolve(type: ImageService.self),
         genreService: GenreService = DIContainer.shared.resolve(type: GenreService.self)
    ) {
        _viewModel = StateObject(wrappedValue: {
            return ViewModel(media: media, size: size, imageService: imageService, genreService: genreService)
        }())
        
    }

    var body: some View {
            HStack {
                Rectangle()
                    .frame(width: viewModel.size == .default ? 120 : 40, height: viewModel.size == .default ? 150 : 50)
                    .opacity(0)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        LinearGradient(colors: [Color("ImagePlaceholder"), Color("ImagePlaceholder").opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(viewModel.image != nil ?
                             Image(uiImage: viewModel.image!)
                        .resizable()
                        .scaledToFill() : nil
                    )
                    .cornerRadius(8)
                    .clipShape(Rectangle())
                
                VStack(alignment: .leading, spacing: 8) {
                    VStack (alignment: .leading) {
                        Text(viewModel.media?.displayedName ?? "")
                            .font(.headline)
                        if viewModel.size == .default {
                            Text(viewModel.media?.overview ?? "")
                                .font(.subheadline)
                                .lineLimit(3)
                        }
                    }
                    
                    
                    ScrollView(.horizontal) { //TODO: prevents selection                     
                        LazyHStack {
                            if let voteAverage = viewModel.media?.voteAverage {
                                Image(systemName: "star.fill")
                                    .frame(width: 20)
                                    .foregroundColor(.yellow)
                                    .shadow(radius: 1)
                                Text(voteAverage)
                                    .fontWeight(Font.Weight.bold)
                                    .foregroundColor(.primary)
                            }
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
                    .offset(.init(width: 0, height: viewModel.size == .default ? 12 : 0))
                    .scrollIndicators(.hidden)
                    .frame(height: viewModel.size == .default ? 40 : 24)
                }
                .frame(height: viewModel.size == .default ? 150 : 50)
                .padding(.leading)
                .padding(.top, viewModel.size == .default ? 12 : 2)
                .padding(.bottom, viewModel.size == .default ? 12 : 2)
            }
            .redacted(reason: viewModel.redacted ? .placeholder : [])
            .task {
               await viewModel.load()
            }
    }
}

extension MediaCellView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var image: UIImage?
        @Published var genres: [Genre] = []
        let size: MediaCellView.Size
        
        var error: ImageError?
        var media: Media?
        var imageService: ImageService
        var genreService: GenreService
        var redacted: Bool
        
        init(
            media: Media? = nil,
            size: MediaCellView.Size = .default,
            imageService: ImageService = DIContainer.shared.resolve(type: ImageService.self),
            genreService: GenreService = DIContainer.shared.resolve(type: GenreService.self)
        ) {
            self.media = media ?? .movie(Movie.preview)
            self.size = size
            self.imageService = imageService
            self.genreService = genreService
            self.redacted = media == nil
        }
        
        func load() async {
            await withTaskGroup(of: Void.self, body: { group in
                group.addTask {
                    await self.loadGenres()
                }

                group.addTask {
                    await self.loadImage()
                }
            })
        }
                
        enum ImageError: String, Error {
            case badURL = "Bad URL"
            case loadError = "Something went wrong while loading"
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
            do {
                let data = try await imageService.loadImage(getImagePath())
                try Task.checkCancellation()
                guard let imageFromData = UIImage(data: data) else {
                    throw ImageError.loadError
                }
                image = imageFromData
                error = nil
            } catch {
                self.error = ImageError.loadError
                image = nil
            }
        }
        
        func getImagePath() throws -> String {
            var posterPath: String?
            var size: String?
            
            guard let media = media else {
                throw ImageError.badURL
            }
            
            switch media {
                case .movie(let movie):
                    posterPath = movie.posterPath
                    size = self.size == .default ? MovieImageSize.PosterSize.w185.rawValue : MovieImageSize.PosterSize.w92.rawValue
                case .tv(let tv):
                    posterPath = tv.posterPath
                    size = self.size == .default ? MovieImageSize.PosterSize.w185.rawValue : MovieImageSize.PosterSize.w92.rawValue
                case .person(let person):
                    posterPath = person.profilePath
                    size = MovieImageSize.ProfileSize.w185.rawValue
            }
            
            guard let path = posterPath, let size = size else {
                throw ImageError.badURL
            }
            
            return ImagePath.path(path: path, size: size)
        }
    }
}


struct MovieCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MediaCellView(media: Media.movie(Movie.preview), genreService: PreviewGenreService())
                .previewLayout(.fixed(width: 500, height: 200))
            Rectangle()
                .frame(height: 20)
            MediaCellView(media: Media.movie(Movie.preview), size: .small, genreService: PreviewGenreService())
                .previewLayout(.fixed(width: 500, height: 200))
        }
    }
}
