//
//  GenreRepository.swift
//  Movies
//
//  Created by Semih Cihan on 29.05.2023.
//

import Foundation
import Combine

protocol GenreRepository: Sendable {
    func genres() async throws -> [Genre]
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
    
    func genres() async throws -> [Genre] {
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
        
        async let (data1, _) = session.data(for: requests[0])
        async let (data2, _) = session.data(for: requests[1])
                    
        let genreSet = try await [data1, data2]
            .map({ d in
                try decoder.decode(GenreResponse.self, from: d)
            })
            .reduce(Set<Genre>(), { partialResult, next in
                return partialResult.union(next.genres)
            })
            
        return Array(genreSet)
    }    
}


private extension RealGenreRepository {
    struct GenreResponse: Decodable, Hashable {
        var genres: Set<Genre>
    }
    
}
