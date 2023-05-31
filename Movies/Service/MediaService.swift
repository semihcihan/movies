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
    func list(page: Int, mediaType: Media.MediaType?, search: String, rating: Int?) -> AnyPublisher<ListSlice<Media>, Error>
}

class RealMediaService: MediaService {
    private let movieRepository: MediaRepository
    
    init(movieRepository: MediaRepository) {
        self.movieRepository = movieRepository
    }
    
    func list(page: Int, mediaType: Media.MediaType?, search: String, rating: Int?) -> AnyPublisher<ListSlice<Media>, Error> {
        if search.count > 0 {
            return movieRepository.searchList(page: 1, perPage: 20, keyword: search)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } else if let rating = rating {
            return movieRepository.discoverList(page: page, perPage: 20, rating: rating, mediaType: mediaType)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        } else {
            return movieRepository.trendingList(page: page, perPage: 20, mediaType: mediaType)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}
