//
//  Store.swift
//  Movies
//
//  Created by Semih Cihan on 20.04.2023.
//

import Foundation

class LikedPhotos {
    static let shared = LikedPhotos()
    
    func addPhoto(_ photo: Photo) {
        if !isLiked(photo) {
            photos.append(photo)
        }
    }
    
    func removePhoto(_ photo: Photo) {
        photos = photos.filter({ $0.id != photo.id })
    }
    
    func isLiked(_ photo: Photo) -> Bool {
        return photos.contains(photo)
    }
    
    private var photos: [Photo] = []
    
    var list: ListResponse<Photo> {
        return ListResponse(page: 0, photos: photos, perPage: 0, totalResults: 0)
    }
}
