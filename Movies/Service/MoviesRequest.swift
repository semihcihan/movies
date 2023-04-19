//
//  MoviesRequest.swift
//  Movies
//
//  Created by Semih Cihan on 19.04.2023.
//

import Foundation

extension NetworkRequest {        
    static func curatedList() -> URLRequest {
        let baseUrl: String = try! PlistReader.value(for: "BASE_URL")
        let auth: String = try! PlistReader.value(for: "AUTHORIZATION")
        return NetworkRequest(baseURL: "https://" + baseUrl, path: "curated", method: .get, headers: ["AUTHORIZATION": auth]).urlRequest
    }
}
