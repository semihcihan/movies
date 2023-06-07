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
    func list(page: Int, mediaType: Media.MediaType?, search: String, rating: Int?) async throws -> ListSlice<Media>
}

final class RealMediaService: MediaService {
    private let movieRepository: MediaRepository
    
    init(movieRepository: MediaRepository) {
        self.movieRepository = movieRepository
    }
    
    func list(page: Int, mediaType: Media.MediaType?, search: String, rating: Int?) async throws -> ListSlice<Media> {
        if search.count > 0 {
            return try await movieRepository.searchList(page: 1, perPage: 20, keyword: search)
        } else if let rating = rating {
            return try await movieRepository.discoverList(page: page, perPage: 20, rating: rating, mediaType: mediaType)
        } else {
            return try await movieRepository.trendingList(page: page, perPage: 20, mediaType: mediaType)                
        }
    }
}
