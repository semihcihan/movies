//
//  ImageWebRepository.swift
//  Movies
//
//  Created by Semih Cihan on 22.05.2023.
//

import Foundation
import Combine

protocol ImageWebRepository {
    func loadImage(_ url: URL) -> AnyPublisher<Data, URLError>
}

struct RealImageWebRepository: ImageWebRepository {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func loadImage(_ url: URL) -> AnyPublisher<Data, URLError> {
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}
