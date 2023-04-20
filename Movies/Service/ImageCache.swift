//
//  ImageCache.swift
//  Movies
//
//  Created by Semih Cihan on 19.04.2023.
//

import Foundation
import Combine

class ImageCache {
    static let shared = ImageCache()

    typealias Publisher = AnyPublisher<Data, URLError>
    private var publishers = [String: Publisher]()
    private var cache: NSCache = NSCache<NSString, NSData>()
    
    func cachedImage(_ url: String) -> NSData? {
        let urlNSString = NSString(string: url)
        let data = cache.object(forKey: urlNSString)        
        return data
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
        
        if let nsdata = cachedImage(urlString) {
            return Just(Data(referencing: nsdata))
                .setFailureType(to: URLError.self)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let urlNSString = NSString(string: urlString)
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [cache, weak self] data in
                cache.setObject(NSData(data: data), forKey: urlNSString, cost: data.count)
                self?.publishers[urlString] = nil
            })
            .share()
            .eraseToAnyPublisher()
        
        publishers[urlString] = publisher
        return publisher
    }
    
}
