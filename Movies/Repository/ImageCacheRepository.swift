//
//  ImageCacheRepository.swift
//  Movies
//
//  Created by Semih Cihan on 22.05.2023.
//

import Foundation
import Combine

protocol ImageCacheRepository: Sendable {
    func cachedImage(_ url: String) -> NSData?
    func cache(_ data: Data, forKey: String, cost: Int?)
}

struct RealImageCacheRepository: ImageCacheRepository, @unchecked Sendable {
    private var cache: NSCache = NSCache<NSString, NSData>()
    
    func cachedImage(_ url: String) -> NSData? {
        let urlNSString = NSString(string: url)
        return cache.object(forKey: urlNSString)
    }
    
    func cache(_ data: Data, forKey: String, cost: Int? = nil) {
        cache.setObject(NSData(data: data), forKey: NSString(string: forKey), cost: cost ?? data.count)
    }
}
