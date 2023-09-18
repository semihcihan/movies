//
//  MovieRepository.swift
//  Movies
//
//  Created by Semih Cihan on 26.04.2023.
//

import Foundation
import Combine

protocol MediaRepository {
    func trendingList(page: Int, perPage: Int, mediaType: Media.MediaType?) async throws -> ListSlice<Media>
    func discoverList(page: Int, perPage: Int, rating: Int, mediaType: Media.MediaType?) async throws -> ListSlice<Media>
    func searchList(page: Int, perPage: Int, keyword: String) async throws -> ListSlice<Media>
}

struct RealMediaRepository: MediaRepository {
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
        guard let baseUrl: String = try? PlistReader.value(for: "BASE_URL"),
              let authorization: String = try? PlistReader.value(for: "AUTHORIZATION") else {
            fatalError("Enter API configuration values")
        }
        self.init(baseUrl: baseUrl, auth: authorization)
    }

    func discoverList(page: Int, perPage: Int, rating: Int, mediaType: Media.MediaType?) async throws -> ListSlice<Media> {
        let queryParams = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "api_key", value: auth),
            URLQueryItem(name: "vote_average.gte", value: String(rating)),
            URLQueryItem(name: "vote_count.gte", value: String(100)),
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]

        if let mediaType = mediaType {
            let request = NetworkRequest(
                baseURL: "https://" + baseUrl,
                path: "discover/\(mediaType.rawValue)",
                queryParameters: queryParams
            ).urlRequest

            let data = try await session.data(for: request).0
            return try decoder.decode(ListSlice<Media>.self, from: data)
        } else {
            let requests = [Media.MediaType.movie, Media.MediaType.tv]
                .map { media in
                    NetworkRequest(
                        baseURL: "https://" + baseUrl,
                        path: "discover/\(media.rawValue)",
                        queryParameters: queryParams
                    ).urlRequest
                }

            async let (data1, _) = session.data(for: requests[0])
            async let (data2, _) = session.data(for: requests[1])

            let response = try await [data1, data2]
                .map({ data in
                    try decoder.decode(ListSlice<Media>.self, from: data)
                })

            return ListSlice(
                page: response[0].page,
                results: response[0].results + response[1].results,
                totalPages: min(response[0].totalPages, response[1].totalPages),
                totalResults: min(response[0].totalResults, response[1].totalResults)
            )
        }

    }

    func searchList(page: Int, perPage: Int, keyword: String) async throws -> ListSlice<Media> {
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

        let data = try await session.data(for: request).0
        return try decoder.decode(ListSlice<Media>.self, from: data)
    }

    func trendingList(page: Int, perPage: Int, mediaType: Media.MediaType?) async throws -> ListSlice<Media> {
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

        let data = try await session.data(for: request).0
        return try decoder.decode(ListSlice<Media>.self, from: data)
    }
}
