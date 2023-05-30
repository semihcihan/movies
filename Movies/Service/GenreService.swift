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
    private let queue = DispatchQueue(label: "GenreLoader")
    private var publisher: Publisher?
    
    var cancellations: [AnyCancellable] = []

    init(genreRepository: GenreRepository) {
        self.genreRepository = genreRepository
    }
    
    func genres() -> Publisher {
        return Just("")
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
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

