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
    func popularList(page: Int) -> AnyPublisher<ListSlice<Movie>, Error>
}

class RealMovieService: MovieService {
    private let movieRepository: MovieRepository
    
    init(movieRepository: MovieRepository) {
        self.movieRepository = movieRepository
    }
    
    func popularList(page: Int) -> AnyPublisher<ListSlice<Movie>, Error> {
        return movieRepository.popularList(page: page, perPage: 10)
    }
}
