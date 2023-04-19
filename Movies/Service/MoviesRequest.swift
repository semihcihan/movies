//
//  MoviesRequest.swift
//  Movies
//
//  Created by Semih Cihan on 19.04.2023.
//

import Foundation

extension NetworkRequest {
    static func curatedList(page: Int = 1) -> URLRequest {
        let queryParams = URLQueryItem(name: "page", value: String(page))
        let baseUrl: String = try! PlistReader.value(for: "BASE_URL")
        let auth: String = try! PlistReader.value(for: "AUTHORIZATION")
        return NetworkRequest(
            baseURL: "https://" + baseUrl,
            path: "curated",
            headers: ["AUTHORIZATION": auth],
            queryParameters: [queryParams]
        ).urlRequest
    }
}
