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
    @EnvironmentObject var navigation: Navigation
    
    var contentHeight: Bool {
        return !viewModel.searchText.isEmpty
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.list, id: \.id) { media in
                    switch media {
                        case .movie(_), .tv(_):
                            MediaCellView(media: media, size: .small)
                                .id(media.id)
                                .onTapGesture {
                                    navigation.path.append(media)
                                }
                        default:
                            fatalError()
                    }
                }
            }
            .searchable(text: $viewModel.searchText)
            .listStyle(.plain)
            .onSubmit(of: .search) {
                viewModel.fetch()
            }
            .onChange(of: viewModel.list, perform: { newValue in
                withAnimation {                    
                    proxy.scrollTo(viewModel.list.first?.id)
                }
            })
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension ScannedMediaView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var list: [Media]
        @Published var error: String?
        @Published var searchText: String
        @Published var contentHeight: CGFloat = 0
        @Published var searching = false
        
        let mediaService: MediaService
        let genreService: GenreService
        
        let height = UIScreen.main.bounds.height / 4
                        
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
            setupContentHeightCallbacks()
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
        
        func setupContentHeightCallbacks() {
            Task {
                for await val in $searchText.values {
                    if val.count == 0 {
                        self.contentHeight = 0
                    } else {
                        self.contentHeight = list.isEmpty ? height : 0
                    }
                }
            }
            
            Task {
                for await val in $list.values {
                    if !val.isEmpty {
                        self.contentHeight = height
                    }
                }
            }
        }
        
        func startExternalSearch(with: String) {
            searchText = with
            fetch()
        }
                
        func fetch() {
            guard !searchText.isEmpty else {
                self.list = []
                self.error = nil
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
