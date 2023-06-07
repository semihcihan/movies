//
//  ListResponse.swift
//  Movies
//
//  Created by Semih Cihan on 17.04.2023.
//

struct ListSlice<T: Decodable>: Decodable where T: Sendable {
    var page: Int
    var results: [T]
    var totalPages: Int
    var totalResults: Int
}
