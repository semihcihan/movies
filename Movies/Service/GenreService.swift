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
    typealias Publisher = AnyPublisher<[Genre], Error>
    private let genreRepository: GenreRepository
    private var cachedGenres: [Genre] = []
    private let queue = DispatchQueue(label: "GenreLoader", qos: .userInitiated)
    private var publisher: Publisher?
    
    var cancellations: [AnyCancellable] = []

    init(genreRepository: GenreRepository) {
        self.genreRepository = genreRepository
    }
    
    func genres() -> Publisher {
        return Just(0)
            .receive(on: queue)
            .flatMap { [weak self, cachedGenres, genreRepository, queue] _ -> Publisher in
                guard cachedGenres.isEmpty else {
                    return Just(cachedGenres).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                            
                if let publisher = self?.publisher {
                    return publisher
                }
                
                let publisher = genreRepository.genres()
                    .receive(on: queue)
                    .handleEvents(receiveOutput: { output in
                        self?.cachedGenres = output
                    })
                    .share()
                    .eraseToAnyPublisher()
                
                self?.publisher = publisher
                return publisher
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

#if DEBUG

struct PreviewGenreService: GenreService {    
    func genres() -> AnyPublisher<[Genre], Error> {
        return Just(
            [
                Genre(id: 1, name: "Action"),
                Genre(id: 2, name: "Thriller"),
                Genre(id: 3, name: "Comedy"),
                Genre(id: 4, name: "Documentary"),
                Genre(id: 5, name: "Horror"),
            ]
        )
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
}

#endif
