//
//  Genre.swift
//  Movies
//
//  Created by Semih Cihan on 29.05.2023.
//

import Foundation

struct Genre: Identifiable, Hashable, Decodable, Equatable {
    var id: Int
    var name: String
}
