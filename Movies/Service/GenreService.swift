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
    func genres() async throws -> [Genre]
    func genres(id: [Int]) async throws -> [Genre]
}

actor RealGenreService: GenreService {
    private let genreRepository: GenreRepository
    private var cachedGenres: [Genre] = []
    private var task: Task<[Genre], Error>?

    init(genreRepository: GenreRepository) {
        self.genreRepository = genreRepository
    }
    
    func genres() async throws -> [Genre] {
        guard cachedGenres.isEmpty else {
            return cachedGenres
        }
        
        if let task = task {
            return try await task.value
        }
        
        task = Task {
            self.cachedGenres = try await genreRepository.genres()
            return self.cachedGenres
        }
                
        return try await task!.value
    }
    
    func genres(id: [Int]) async throws -> [Genre] {
        return try await genres().filter({ genre in
            id.contains(genre.id)
        })
    }
}

#if DEBUG

struct PreviewGenreService: GenreService {
    
    func genres() async throws -> [Genre] {
        return [
            Genre(id: 1, name: "Action"),
            Genre(id: 2, name: "Thriller"),
            Genre(id: 3, name: "Comedy"),
            Genre(id: 4, name: "Documentary"),
            Genre(id: 5, name: "Horror"),
        ]
    }
    
    func genres(id: [Int]) async throws -> [Genre] {
        return []
    }
}

#endif
