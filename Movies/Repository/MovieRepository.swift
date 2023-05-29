//
//  MovieRepository.swift
//  Movies
//
//  Created by Semih Cihan on 26.04.2023.
//

import Foundation
import Combine

protocol MovieRepository {
    func trendingList(page: Int, perPage: Int, mediaType: Media.MediaType?) -> AnyPublisher<ListSlice<Media>, Error>
    func discoverList(page: Int, perPage: Int, rating: Int, mediaType: Media.MediaType?) -> AnyPublisher<ListSlice<Media>, Error>
    func searchList(page: Int, perPage: Int, keyword: String) -> AnyPublisher<ListSlice<Media>, Error>
}

struct RealMovieRepository: MovieRepository {
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
    
    func discoverList(page: Int, perPage: Int, rating: Int, mediaType: Media.MediaType?) -> AnyPublisher<ListSlice<Media>, Error> {
        let queryParams = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "api_key", value: auth),
            URLQueryItem(name: "vote_average.gte", value: String(rating)),
            URLQueryItem(name: "vote_count.gte", value: String(100))
        ]
        
        let request = NetworkRequest(
            baseURL: "https://" + baseUrl,
            path: "discover/movie",
            queryParameters: queryParams
        ).urlRequest
                
        return URLSession.shared
            .decodedTaskPublisher(for: request, decoder: decoder, decodeTo: ListSlice<Media>.self)

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
