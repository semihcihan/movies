//
//  ListViewModel.swift
//  Movies
//
//  Created by Semih Cihan on 17.04.2023.
//

import Foundation
import Combine
import Algorithms

class ListViewModel: ObservableObject {
    @Published var list: ListResponse<Photo>?
    var error: String?
    
    var cancellable: AnyCancellable?
    
    var canRequestMore: Bool {
        guard let list = list else {
            return true
        }
        return !(list.nextPage ?? "").isEmpty
    }
    
    func fetch() {
        guard canRequestMore else {
            return
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        cancellable = URLSession.shared
            .dataTaskPublisher(for: NetworkRequest.curatedList(page: (self.list?.page ?? 0) + 1))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: ListResponse<Photo>.self, decoder: decoder)
            .map({ [weak self] listResponse in
                ListResponse(
                    page: listResponse.page,
                    photos: Array(((self?.list?.photos ?? []) + listResponse.photos).uniqued()),
                    perPage: listResponse.perPage,
                    totalResults: listResponse.totalResults,
                    nextPage: listResponse.nextPage
                )
            })            
            .receive(on: DispatchQueue.main)
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
