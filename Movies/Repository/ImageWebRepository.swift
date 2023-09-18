//
//  ImageWebRepository.swift
//  Movies
//
//  Created by Semih Cihan on 22.05.2023.
//

import Foundation
import Combine

protocol ImageWebRepository: Sendable {
    func loadImage(_ url: URL) async throws -> Data
}

final class RealImageWebRepository: NSObject, ImageWebRepository {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func loadImage(_ url: URL) async throws -> Data {
        return try await session.data(from: url).0
    }
}
