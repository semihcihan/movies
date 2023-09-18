//
//  PhotoCellView.swift
//  Movies
//
//  Created by Semih Cihan on 18.04.2023.
//

import SwiftUI
import Combine

struct MediaCellView: View {
    @Environment(\.dynamicTypeSize) var typeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @StateObject var viewModel: ViewModel
    
    init(media: Media?,
         size: Size = .default,
         imageService: ImageService = DIContainer.shared.resolve(type: ImageService.self),
         genreService: GenreService = DIContainer.shared.resolve(type: GenreService.self)
    ) {
        _viewModel = StateObject(wrappedValue: ViewModel(media: media, size: size, imageService: imageService, genreService: genreService))
    }
    
    enum Size {
        case `default`
        case small
    }
    
    private var sizeMultiplier: Double {
        return typeSize > DynamicTypeSize.large || (horizontalSizeClass == .regular && verticalSizeClass == .regular) ? 1.2 : 1
    }
    
    private var imageViewSize: CGSize {
        switch viewModel.size {
            case .default:
                return CGSize(width: 120 * sizeMultiplier, height: 150 * sizeMultiplier)
            case .small:
                return CGSize(width: 40 * sizeMultiplier, height: 50 * sizeMultiplier)
        }
    }
    
    private var genreViewHeight: Double {
        switch viewModel.size {
            case .default:
                return 40 * sizeMultiplier
            case .small:
                return 24 * sizeMultiplier
        }
    }
    
    private var mediaTypeImageName: String {
        switch viewModel.media {
            case .movie(_):
                return "popcorn.fill"
            case .tv(_):
                return "tv.fill"
            case .person(_):
                return "person.fill"
            case .none:
                return "popcorn.fill"
        }
    }
    
    @ViewBuilder
    var image: some View {
        Rectangle()
            .frame(width: imageViewSize.width, height: imageViewSize.height)
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
    }

    var body: some View {
            HStack {
                image
                
                VStack(alignment: .leading, spacing: 8) {
                    VStack (alignment: .leading, spacing: 8) {
                        Text(viewModel.media?.displayedName ?? "")
                            .font(.title2)
                            .fontWeight(.semibold)
                        if viewModel.size == .default {
                            Text(viewModel.media?.overview ?? "")
                                .font(.subheadline)
                                .lineLimit(3)
                        }
                    }
                    
                    ScrollView(.horizontal) {                     
                        LazyHStack {
                            HStack(spacing: 12) {
                                if let voteAverage = viewModel.media?.voteAverage {
                                    HStack(spacing: 4) {
                                        Text(Image(systemName: "star.fill"))
                                            .foregroundColor(.yellow)
                                            .shadow(color: .black, radius: 0.5)
                                            .font(.footnote)
                                        Text(voteAverage)
                                            .fontWeight(Font.Weight.bold)
                                            .foregroundColor(.primary)
                                    }
                                }
                                Text(Image(systemName: mediaTypeImageName))
                                    .foregroundColor(.secondary)
                            }
                            Divider()
                                .frame(height: 12)
                                .opacity(viewModel.genres.count > 0 ? 1 : 0)
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
                    .frame(height: genreViewHeight)
                }
                .frame(height: imageViewSize.height)
                .padding(.leading)
                .padding(.vertical, viewModel.size == .default ? 12 : 2)
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
            MediaCellView(media: Media.movie(Movie.previewShortOverview), genreService: PreviewGenreService())
                .previewLayout(.fixed(width: 500, height: 200))
            Rectangle()
                .frame(height: 20)
            MediaCellView(media: Media.movie(Movie.preview), size: .small, genreService: PreviewGenreService())
                .previewLayout(.fixed(width: 500, height: 200))
        }
    }
}
