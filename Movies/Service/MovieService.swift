//
//  MoviesRequest.swift
//  Movies
//
//  Created by Semih Cihan on 19.04.2023.
//

import Foundation
import Combine
import SwiftUI

protocol MovieService {
    func list(page: Int, mediaType: Media.MediaType?, search: String, rating: Int?) -> AnyPublisher<ListSlice<Media>, Error>
}

class RealMovieService: MovieService {
    private let movieRepository: MovieRepository
    
    init(movieRepository: MovieRepository) {
        self.movieRepository = movieRepository
    }
    
    func list(page: Int, mediaType: Media.MediaType?, search: String, rating: Int?) -> AnyPublisher<ListSlice<Media>, Error> {
        if search.count > 0 {
            return movieRepository.searchList(page: 1, perPage: 20, keyword: search)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } else if let rating = rating {
            return movieRepository.discoverList(page: 1, perPage: page, rating: rating, mediaType: mediaType)//
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        } else {
            return movieRepository.trendingList(page: page, perPage: 10, mediaType: mediaType)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}

//    .map {
        //                var slice = $0
        //                if let mediaType = mediaType {
        //                    slice.results = slice.results.map { media in
        //                        var media = media
        //                        media.mediaType = mediaType
        //                        return media
        //                    }
        //                }
        //                return slice
        //            }

