//
//  PhotoCellViewModel.swift
//  Movies
//
//  Created by Semih Cihan on 18.04.2023.
//

import Foundation
import UIKit
import Combine

class PhotoCellViewModel: ObservableObject {
    @Published var image: UIImage?
    var error: ImageError?
    var photo: Photo?
    var cancellable: Cancellable?
    
    init(photo: Photo? = nil) {
        self.photo = photo
    }
    
    enum ImageError: String, Error {
        case badURL = "Bad URL"
        case loadError = "Something went wrong while loading"
    }
        
    func loadImage(_ keyPath: KeyPath<Source, String>) {
        guard let urlString = photo?.src[keyPath: keyPath] else {
            self.error = ImageError.badURL
            return
        }

        self.cancellable = ImageCache.shared.loadImage(urlString).sink { [weak self] _ in
            self?.error = ImageError.loadError
        } receiveValue: { [weak self] data in
            guard let image = UIImage(data: data) else {
                self?.error = ImageError.loadError
                return
            }
            self?.image = image
            self?.error = nil
        }
    }
    
    func releaseImage() {
        self.cancellable = nil
        self.image = nil
        self.error = nil
    }

}
