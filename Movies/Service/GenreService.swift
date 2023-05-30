//
//  GenreService.swift
//  Movies
//
//  Created by Semih Cihan on 29.05.2023.
//

import Foundation
import Combine
import SwiftUI

protocol GenreService {
    func genres() -> AnyPublisher<[Genre], Error>
}

class RealGenreService: GenreService {
    private let genreRepository: GenreRepository
    private var localGenres: [Genre] = []
    
    init(genreRepository: GenreRepository) {
        self.genreRepository = genreRepository
    }
    
    func genres() -> AnyPublisher<[Genre], Error> {
        guard localGenres.isEmpty else {
            return Just(localGenres).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        return genreRepository.genres()
            .map({ [weak self] in
                self?.localGenres = $0
                return $0
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

