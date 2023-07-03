//
//  MoviesRequest.swift
//  Movies
//
//  Created by Semih Cihan on 19.04.2023.
//

import Foundation
import Combine
import SwiftUI

protocol MediaService {
    func list(page: Int, perPage: Int, mediaType: Media.MediaType?, search: String, rating: Int?) async throws -> ListSlice<Media>
}

extension MediaService {
    func list(page: Int, mediaType: Media.MediaType?, search: String, rating: Int?) async throws -> ListSlice<Media> {
        return try await list(page: page, perPage: 20, mediaType: mediaType, search: search, rating: rating)
    }
}

final class RealMediaService: MediaService {
    private let movieRepository: MediaRepository
    
    init(movieRepository: MediaRepository) {
        self.movieRepository = movieRepository
    }
    
    func list(page: Int, perPage: Int = 20, mediaType: Media.MediaType?, search: String, rating: Int?) async throws -> ListSlice<Media> {
        if search.count > 0 {
            return try await movieRepository.searchList(page: 1, perPage: perPage, keyword: search)
        } else if let rating = rating {
            var result = try await movieRepository.discoverList(page: page, perPage: perPage, rating: rating, mediaType: mediaType)
            result.results.sort { $0.popularity > $1.popularity }
            return result
        } else {
            return try await movieRepository.trendingList(page: page, perPage: perPage, mediaType: mediaType)
        }
    }
}


final class MockMediaService: MediaService {
    func list(page: Int, perPage: Int = 20, mediaType: Media.MediaType?, search: String, rating: Int?) async throws -> ListSlice<Media> {
        try? await Task.sleep(for: .seconds(0.3))
        return ListSlice(page: 0, results: [Media.movie(Movie.preview)], totalPages: 1, totalResults: 1)        
    }
}
