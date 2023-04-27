//
//  MovieRepository.swift
//  Movies
//
//  Created by Semih Cihan on 26.04.2023.
//

import Foundation
import Combine

protocol MovieRepository {
    func popularList(page: Int, perPage: Int) -> AnyPublisher<ListSlice<Movie>, Error>
}

struct RealMovieRepository: MovieRepository {
    private let baseUrl: String
    private let auth: String
    
    init() {
        baseUrl = try! PlistReader.value(for: "BASE_URL")
        auth = try! PlistReader.value(for: "AUTHORIZATION")
    }
    
    func popularList(page: Int, perPage: Int) -> AnyPublisher<ListSlice<Movie>, Error> {
        let queryParams = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "api_key", value: auth)
        ]
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let request = NetworkRequest(
            baseURL: "https://" + baseUrl,
            path: "movie/popular",
            queryParameters: queryParams
        ).urlRequest
        
        return URLSession.shared
            .decodedTaskPublisher(for: request, decoder: decoder, decodeTo: ListSlice<Movie>.self)
    }
}
