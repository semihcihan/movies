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
    
    private var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    init(baseUrl: String, auth: String) {
        self.baseUrl = baseUrl
        self.auth = auth
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
                URLSession.shared.decodedTaskPublisher(for: $0, decoder: decoder, decodeTo: GenreResponse.self)
            }
        
        return Publishers.Zip(dataTaskPublishers[0], dataTaskPublishers[1])
            .compactMap { a, b in
                return a.genres + b.genres
            }
            .eraseToAnyPublisher()
    }
    
    func searchList(page: Int, perPage: Int, keyword: String) -> AnyPublisher<ListSlice<Media>, Error> {
        let queryParams = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "api_key", value: auth),
            URLQueryItem(name: "query", value: keyword)
        ]
        
        let request = NetworkRequest(
            baseURL: "https://" + baseUrl,
            path: "search/multi",
            queryParameters: queryParams
        ).urlRequest
        
        return URLSession.shared
            .decodedTaskPublisher(for: request, decoder: decoder, decodeTo: ListSlice<Media>.self)
    }
    
    func trendingList(page: Int, perPage: Int, mediaType: Media.MediaType?) -> AnyPublisher<ListSlice<Media>, Error> {
        let queryParams = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "api_key", value: auth)
        ]
        
        let mediaTypePath = mediaType != nil ? mediaType!.rawValue : "all"
        
        let request = NetworkRequest(
            baseURL: "https://" + baseUrl,
            path: "trending/\(mediaTypePath)/week",
            queryParameters: queryParams
        ).urlRequest
        
        return URLSession.shared
            .decodedTaskPublisher(for: request, decoder: decoder, decodeTo: ListSlice<Media>.self)
    }
}


private extension RealGenreRepository {
    struct GenreResponse: Decodable {
        var genres: [Genre]            
    }
    
}
