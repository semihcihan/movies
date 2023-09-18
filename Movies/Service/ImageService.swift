//
//  ImageService.swift
//  Movies
//
//  Created by Semih Cihan on 22.05.2023.
//

import Foundation
import Combine

protocol ImageService {
    func loadImage(_ urlString: String) async throws -> Data
}

actor RealImageService: ImageService {
    private let webRepository: ImageWebRepository
    private let cacheRepository: ImageCacheRepository
    private var tasks = [String: Task<Data, Error>]()

    init(webRepository: ImageWebRepository = RealImageWebRepository(), cacheRepository: ImageCacheRepository = RealImageCacheRepository()) {
        self.webRepository = webRepository
        self.cacheRepository = cacheRepository
    }

    func loadImage(_ urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        if let task = tasks[urlString] {
            return try await task.value
        }

        let task = Task {
            if let nsdata = cacheRepository.cachedImage(urlString) {
                tasks[urlString] = nil
                return Data(referencing: nsdata)
            }

            defer {
                tasks[urlString] = nil
            }
            let imageData = try await webRepository.loadImage(url)
            cacheRepository.cache(imageData, forKey: urlString, cost: nil)
            return imageData
        }

        tasks[urlString] = task
        return try await task.value
    }

}
