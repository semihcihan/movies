//
//  DecodedTaskPublisher.swift
//  Movies
//
//  Created by Semih Cihan on 26.04.2023.
//

import Foundation
import Combine

extension URLSession {
    func decodedTaskPublisher<T : Decodable>(for request: URLRequest, decoder: JSONDecoder, decodeTo: T.Type) -> AnyPublisher<T, Error> {
        return self
            .dataTaskPublisher(for: request)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
