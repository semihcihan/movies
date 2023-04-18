//
//  Photo.swift
//  Movies
//
//  Created by Semih Cihan on 18.04.2023.
//

struct Photo: Identifiable, Equatable, Decodable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographerUrl: String
    let photographerId: Int
    let avgColor: String
    let liked: Bool
    let alt: String
    let src: Source
}

struct Source: Decodable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
}

extension Photo {
    static var preview: Photo = Photo(
        id: 1,
        width: 3434,
        height: 4578,
        url: "https://www.pexels.com/photo/fashion-person-people-woman-16275007/",
        photographer: "Lany-Jade Mondou",
        photographerUrl: "https://www.pexels.com/@lany",
        photographerId: 135943481,
        avgColor: "#ACA89F",
        liked: false, alt: "Free stock photo of 35mm, aesthetic, attractive woman",
        src: Source(
            original: "https://images.pexels.com/photos/16275007/pexels-photo-16275007.jpeg",
            large2x: "https://images.pexels.com/photos/16275007/pexels-photo-16275007.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
            large: "https://images.pexels.com/photos/16275007/pexels-photo-16275007.jpeg?auto=compress&cs=tinysrgb&h=650&w=940",
            medium: "https://images.pexels.com/photos/16275007/pexels-photo-16275007.jpeg?auto=compress&cs=tinysrgb&h=350",
            small: "https://images.pexels.com/photos/16275007/pexels-photo-16275007.jpeg?auto=compress&cs=tinysrgb&h=130",
            portrait: "https://images.pexels.com/photos/16275007/pexels-photo-16275007.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800",
            landscape: "https://images.pexels.com/photos/16275007/pexels-photo-16275007.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=627&w=1200",
            tiny: "https://images.pexels.com/photos/16275007/pexels-photo-16275007.jpeg?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280"
        )
    )
}
