//
//  ScannedMediaView.swift
//  Movies
//
//  Created by Semih Cihan on 12.06.2023.
//

import SwiftUI
import Combine
import UIKit

struct ScannedMediaView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.list, id: \.id) { media in
                    switch media {
                        case .movie(_), .tv(_):
                            NavigationLink(value: media) {
                                MediaCellView(media: media, size: .small)
                            }
                        default:
                            fatalError()
                    }
                }
            }
            .searchable(text: $viewModel.searchText) //TODO: dismiss focus on scroll
            .listStyle(.plain)
            .onSubmit(of: .search) {
                viewModel.fetch()
            }
            .navigationDestination(for: Media.self) { movie in
                MediaDetailView(media: movie)
            }
            .onAppear {
                viewModel.fetch()
            }
            .frame(minHeight: viewModel.searchText.count > 0 ? 220 : 50)
            .toolbarBackground(.hidden, for: .navigationBar)
        }

    }
}

extension ScannedMediaView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var list: [Media]
        @Published var error: String?
        @Published var searchText: String
        
        let mediaService: MediaService
        let genreService: GenreService
                        
        init(list: [Media] = [],
             error: String? = nil,
             searchResults: [Media] = [],
             searchText: String = "",
             mediaService: MediaService = DIContainer.shared.resolve(type: MediaService.self),
             genreService: GenreService = DIContainer.shared.resolve(type: GenreService.self)) {
            self.error = error
            self.list = list
            self.mediaService = mediaService
            self.genreService = genreService
            self.searchText = searchText
            
            setupFilterCallbacks()
        }
        
        func setupFilterCallbacks() {
            Task { [weak self] in
                guard let self = self else {
                    return
                }
                for await val in self.$searchText.values.dropFirst() {
                    if val.count == 0 {
                        self.list = []
                    }
                }
            }
        }
                
        func fetch() {
            guard !searchText.isEmpty else {
                return
            }
            Task {
                do {
                    let result = try await mediaService.list(
                        page: 1,
                        perPage: 3,
                        mediaType: nil,
                        search: searchText,
                        rating: nil)
                    self.list = result.results.filter({ media in
                        switch media {
                            case .movie(_), .tv(_):
                                return true
                            case .person(_):
                                return false
                        }
                    })
                    self.error = nil
                } catch {
                    self.error = error.localizedDescription
                }
            }
        }
    }
}

extension ScannedMediaView {
    static func hostingVC() -> (Self, UIView) {
        let view = ScannedMediaView(viewModel: ScannedMediaView.ViewModel())
        let hostingVC = UIHostingController(rootView: view)
        hostingVC.view.backgroundColor = .red
        
        return (view, hostingVC.view)
    }
}

struct ScannedMediaView_Previews: PreviewProvider {
    @State static var isPresented = true
    
    static var previews: some View {
        Rectangle()
        .background(.red)
        .sheet(isPresented: $isPresented, content: {
            Rectangle().background(.green)
            ScannedMediaView(viewModel: ScannedMediaView.ViewModel(searchText: "Inter", mediaService: RealMediaService(movieRepository: RealMediaRepository())))
                .frame(height: 350)
        })
    }
}
