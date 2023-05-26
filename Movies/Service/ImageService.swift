//
//  ImageService.swift
//  Movies
//
//  Created by Semih Cihan on 22.05.2023.
//

import Foundation
import Combine

typealias Publisher = AnyPublisher<Data, URLError>

protocol ImageService {
    func loadImage(_ urlString: String) -> Publisher
}

class RealImageService: ImageService {
    private let webRepository: ImageWebRepository
    private let cacheRepository: ImageCacheRepository
    private var publishers = [String: Publisher]()
    
    init(webRepository: ImageWebRepository = RealImageWebRepository(), cacheRepository: ImageCacheRepository = RealImageCacheRepository()) {
        self.webRepository = webRepository
        self.cacheRepository = cacheRepository
    }
    
    func loadImage(_ urlString: String) -> Publisher {
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        if let publisher = publishers[urlString] {
            return publisher
        }
        
        if let nsdata = cacheRepository.cachedImage(urlString) {
            return Just(Data(referencing: nsdata))
                .setFailureType(to: URLError.self)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

        let publisher = webRepository.loadImage(url)
            .handleEvents(receiveOutput: { [cacheRepository, weak self] data in
                cacheRepository.cache(data, forKey: urlString, cost: nil)
                self?.publishers[urlString] = nil
            })
            .eraseToAnyPublisher()
        
        publishers[urlString] = publisher
        
        return publisher
    }

}
