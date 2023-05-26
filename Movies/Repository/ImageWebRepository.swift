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

class RealImageWebRepository: ImageWebRepository {
    func loadImage(_ url: URL) -> AnyPublisher<Data, URLError> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .share()
            .eraseToAnyPublisher()
    }
}
