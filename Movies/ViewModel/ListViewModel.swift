//
//  ListViewModel.swift
//  Movies
//
//  Created by Semih Cihan on 17.04.2023.
//

import Foundation

class ListViewModel: ObservableObject {
    @Published var list: ListResponse<Photo>?
    var error: String?
    var page: Int = 0
    var totalPages: Int = 0
    
    func fetch() {
        do {
            if let bundlePath = Bundle.main.path(forResource: "sample_list_small", ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                let decorder = JSONDecoder()
                decorder.keyDecodingStrategy = .convertFromSnakeCase
                self.list = try decorder.decode(ListResponse<Photo>.self, from: jsonData)
            }
        } catch {
            print(error)
        }
    }
}
