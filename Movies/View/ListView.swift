//
//  ListView.swift
//  Movies
//
//  Created by Semih Cihan on 17.04.2023.
//

import SwiftUI
import Combine

struct ListView: View {    
    @ObservedObject var viewModel: ViewModel
        
    var body: some View {
        NavigationStack {
            List(viewModel.list) { movie in
                MovieCellView(movie: movie)
            }
            if viewModel.canRequestMore {
                ProgressView()
                    .padding()
                    .onAppear {
                        viewModel.fetch()
                    }
            }
        }        
    }
}

extension ListView {
    class ViewModel: ObservableObject {
        @Published var list: [Movie]
        @Published var error: String?
        var page: Int = 0
        var totalPages: Int = 1
        let service: MovieService
        var cancellable: AnyCancellable?
        
        init(list: [Movie] = [], error: String? = nil, service: MovieService) {
            self.error = error
            self.list = list
            self.service = service
        }
                
        var canRequestMore: Bool {
            return totalPages > page
        }
        
        func fetch() {
            guard canRequestMore else {
                return
            }
            
            cancellable = service.popularList(page: page + 1)
                .sink(receiveCompletion: { [weak self] failure in
                    switch failure {
                        case .failure(let err):
                            self?.error = err.localizedDescription
                        default:
                            break
                    }
                }, receiveValue: { [weak self] output in
                    self?.list = output.results
                    self?.page = output.page
                    self?.totalPages = output.totalPages
                    self?.error = nil
                })
        }
    }

}


//
//struct ListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListView(viewModel: ListView.ViewModel(service: RealMovieService()))
//    }
//}
