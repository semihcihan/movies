//
//  ListResponse.swift
//  Movies
//
//  Created by Semih Cihan on 17.04.2023.
//

struct ListResponse<T: Decodable>: Decodable {
    var page: Int
    var photos: [T]
    var perPage: Int
    var totalResults: Int
}
