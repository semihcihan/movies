//
//  GenreRepository.swift
//  Movies
//
//  Created by Semih Cihan on 29.05.2023.
//

import Foundation
import Combine

protocol GenreRepository: Sendable {
    func genres() async throws -> [Media.MediaType: [Genre]]
}

struct RealGenreRepository: GenreRepository {
    private let baseUrl: String
    private let auth: String
    private let session: URLSession
    
    private var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    init(baseUrl: String, auth: String, session: URLSession = .shared) {
        self.baseUrl = baseUrl
        self.auth = auth
        self.session = session
    }
    
    init() {
        self.init(baseUrl: try! PlistReader.value(for: "BASE_URL"), auth: try! PlistReader.value(for: "AUTHORIZATION"))
    }
    
    func genres() async throws -> [Media.MediaType: [Genre]] {
        let queryParams = [
            URLQueryItem(name: "api_key", value: auth)
        ]
                
        let requests = [Media.MediaType.movie, Media.MediaType.tv]
            .map { media in
                NetworkRequest(
                    baseURL: "https://" + baseUrl,
                    path: "genre/\(Media.MediaType.movie.rawValue)/list",
                    queryParameters: queryParams
                ).urlRequest
            }
        
        async let (movieGenreResponse, _) = session.data(for: requests[0])
        async let (tvGenreResponse, _) = session.data(for: requests[1])
                    
        let genres = try await [movieGenreResponse, tvGenreResponse]
            .map({ d in
                try decoder.decode(GenreResponse.self, from: d).genres
            })
            
        return [.movie: Array(genres[0]), .tv: Array(genres[1])]
    }    
}


private extension RealGenreRepository {
    struct GenreResponse: Decodable, Hashable {
        var genres: Set<Genre>
    }
}
