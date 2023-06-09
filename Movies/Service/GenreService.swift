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
    func genres(mediaType: Media.MediaType?) async throws -> [Genre]
    func genres(id: [Int]) async throws -> [Genre]
}

actor RealGenreService: GenreService {
    private let genreRepository: GenreRepository
    private var cachedGenres: [Media.MediaType: [Genre]]?
    private var task: Task<[Genre], Error>?

    init(genreRepository: GenreRepository) {
        self.genreRepository = genreRepository
    }
    
    static func mediaTypeToGenres(mediaType: Media.MediaType? = nil, genres: [Media.MediaType: [Genre]]) -> [Genre] {
        if let mediaType = mediaType {
            return genres[mediaType] ?? []
        } else {
            return Array(Set((genres[.movie] ?? []) + (genres[.tv] ?? [])))
        }
    }
    
    func genres(mediaType: Media.MediaType? = nil) async throws -> [Genre] {
        if let cachedGenres = cachedGenres {
            return Self.mediaTypeToGenres(mediaType: mediaType, genres: cachedGenres)
        }
        
        if let task = task {
            return try await task.value
        }
        
        task = Task {
            cachedGenres = try await genreRepository.genres()
            return Self.mediaTypeToGenres(mediaType: mediaType, genres: cachedGenres!)
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
    func genres(mediaType: Media.MediaType?) async throws -> [Genre] {
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
