//
//  NetworkService.swift
//  Movies
//
//  Created by Semih Cihan on 19.04.2023.
//

import Foundation

struct NetworkRequest {
    var baseURL: String
    var path: String
    var method: HttpMethod = .get
    var httpBody: Encodable?
    var headers: [String: String]?
    var queryParameters: [URLQueryItem]?
    var timeout: TimeInterval?

    var urlRequest: URLRequest {
        guard let url = self.url else {
            fatalError("URL could not be built")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = timeout ?? 30

        if let httpBody = httpBody {
            request.httpBody = try? httpBody.jsonEncode()
        }

        return request
    }

    var url: URL? {
        let urlComponents = URLComponents(string: baseURL)
        guard var components = urlComponents else {
            return URL(string: baseURL)
        }

        components.path = components.path.appending(path)

        guard let queryParams = queryParameters else {
            return components.url
        }

        if components.queryItems == nil {
            components.queryItems = []
        }

        components.queryItems?.append(contentsOf: queryParams)

        return components.url
    }
}

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
    case connect = "CONNECT"
    case head = "HEAD"
    case options = "OPTIONS"
    case put = "PUT"
    case trace = "TRACE"
}

private extension Encodable {
    func jsonEncode() throws -> Data? {
        try JSONEncoder().encode(self)
    }
}
