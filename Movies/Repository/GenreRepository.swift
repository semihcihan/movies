//
//  GenreRepository.swift
//  Movies
//
//  Created by Semih Cihan on 29.05.2023.
//

import Foundation
import Combine

protocol GenreRepository {
    func genres() -> AnyPublisher<[Genre], Error>
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
    
    func genres() -> AnyPublisher<[Genre], Error> {
        let queryParams = [
            URLQueryItem(name: "api_key", value: auth)
        ]

        let dataTaskPublishers = [Media.MediaType.movie, Media.MediaType.tv]
            .map {
                NetworkRequest(
                    baseURL: "https://" + baseUrl,
                    path: "genre/\($0.rawValue)/list",
                    queryParameters: queryParams
                ).urlRequest
            }
            .map {
                session.decodedTaskPublisher(for: $0, decoder: decoder, decodeTo: GenreResponse.self)
            }
        
        return Publishers.Zip(dataTaskPublishers[0], dataTaskPublishers[1])
            .compactMap { a, b in
                return  Array(a.genres.union(b.genres))
            }
            .eraseToAnyPublisher()
    }
}


private extension RealGenreRepository {
    struct GenreResponse: Decodable, Hashable {
        var genres: Set<Genre>
    }
    
}
