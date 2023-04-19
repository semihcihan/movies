//
//  ListViewModel.swift
//  Movies
//
//  Created by Semih Cihan on 17.04.2023.
//

import Foundation
import Combine

class ListViewModel: ObservableObject {
    @Published var list: ListResponse<Photo>?
    var error: String?
    var page: Int = 0
    var totalPages: Int = 0
    
    var cancellable: AnyCancellable?
    
    func fetch() {        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        cancellable = URLSession.shared
            .dataTaskPublisher(for: NetworkRequest.curatedList())
            .receive(on: DispatchQueue.main)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: ListResponse<Photo>.self, decoder: decoder)
            .sink(receiveCompletion: { [weak self] failure in
                switch failure {
                    case .failure(let err):
                        self?.error = err.localizedDescription
                    default:
                        break
                }
            }, receiveValue: { [weak self] output in
                self?.list = output
            })
                
    }
}
