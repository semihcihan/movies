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
        NavigationStack(path: $viewModel.path) {
            Group {
                
                if viewModel.list.count > 0 || viewModel.selectedMediaIndex != nil || viewModel.selectedRatingIndex != nil {
                    List {
                        Section {
                            ForEach(viewModel.searchText.count > 0 ? viewModel.searchResults : viewModel.list, id: \.id) { media in
                                
                                switch media {
                                    case .movie(_), .tv(_):
                                        NavigationLink(value: media) {
                                            MediaCellView(media: media)
                                        }
                                    default:
                                        MediaCellView(media: media)
                                }                                
                            }
                            
                            if viewModel.searchText.count == 0 && viewModel.canRequestMore {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                .id(UUID())
                                .padding()
                                .onAppear {
                                    viewModel.fetch()
                                }
                            }
                        } header: {
                            if viewModel.searchText.count == 0 {
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .frame(width: 20)
                                        CrumbSelection(selectedTitleIndex: $viewModel.selectedRatingIndex, titles: viewModel.ratings.map{ String($0) + "+" } )
                                        Spacer()
                                    }
                                    HStack {
                                        Image(systemName: "play.fill")
                                            .frame(width: 20)
                                        CrumbSelection(selectedTitleIndex: $viewModel.selectedMediaIndex, titles: ["Movie", "TV"])
                                        Spacer()
                                    }
                                }
                                .padding(.leading, -20)
                                .padding(.bottom, 6)
                                .padding(.top, -12)
                            }
                        }
                    }
                    .searchable(text: $viewModel.searchText)
                    .onSubmit(of: .search) {
                        viewModel.fetch()
                    }
                    .navigationDestination(for: Media.self) { movie in
                        MediaDetailView(media: movie)
                    }
                    .navigationDestination(for: String.self, destination: { _ in
                        ScannerViewControllerRepresentable()
                    })
                } else {
                    List {
                        MediaCellView(media: nil)
                        MediaCellView(media: nil)
                        MediaCellView(media: nil)
                        MediaCellView(media: nil)
                        MediaCellView(media: nil)
                    }
                    .onAppear {
                        viewModel.fetch()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        //TODO: check availability
                        /**
                         var scannerAvailable: Bool {
                         DataScannerViewController.isSupported &&
                         DataScannerViewController.isAvailable
                         }
                         */
                        viewModel.path.append("")
                    } label: {
                        Image(systemName: "camera.fill")
                    }
                    
                }
            }
            .navigationBarTitle("Movie Vision", displayMode: .large)

        }
    }
}

//TODO: check internet connection

extension ListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var list: [Media]
        @Published var searchResults: [Media]
        @Published var error: String? //TODO: error display
        @Published var path: NavigationPath = NavigationPath()
        @Published var selectedMediaIndex: Int?
        @Published var searchText: String
        @Published var selectedRatingIndex: Int?
        @Published var selectedCategoryIndex: Int?
        
        let ratings: [Int] = [6, 7, 8, 9]
        let mediaService: MediaService
        let genreService: GenreService

        var selectedRating: Int?
        var mediaType: Media.MediaType?
        var page: Int = 0
        var totalPages: Int = 1

        var selectedMediaCancellable: AnyCancellable?
        var searchCancellable: AnyCancellable?
        var selectedRatingCancellable: AnyCancellable?
        
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
            self.searchResults = searchResults
            
            setupFilterCallbacks()
        }
        
        func setupFilterCallbacks() {
            Task { [weak self] in
                guard let self = self else {
                    return
                }
                for await index in self.$selectedMediaIndex.values.dropFirst() {
                    switch index {
                        case 0:
                            self.mediaType = .movie
                        case 1:
                            self.mediaType = .tv
                        default:
                            self.mediaType = nil
                    }
                    
                    self.page = 0
                    self.totalPages = 1
                    self.fetch()
                }
            }
            
            Task { [weak self] in
                guard let self = self else {
                    return
                }
                for await index in self.$selectedRatingIndex.values.dropFirst() {
                    if let index = index {
                        self.selectedRating = self.ratings[index]
                    } else {
                        self.selectedRating = nil
                    }
                    
                    self.page = 0
                    self.totalPages = 1
                    self.fetch()
                }
            }
            
            Task { [weak self] in
                guard let self = self else {
                    return
                }
                for await val in self.$searchText.values.dropFirst() {
                    if val.count == 0 {
                        self.searchResults = []
                    }
                }
            }
        }
        
        var canRequestMore: Bool {
            return totalPages > page
        }
        
        func fetch() {
            Task {
                let isSearch = searchText.count > 0
                guard isSearch || canRequestMore else {
                    return
                }
                
                do {
                    let result = try await mediaService.list(
                        page: searchText.count > 0 ? 1 : page + 1,
                        mediaType: mediaType,
                        search: searchText,
                        rating: selectedRating)
                    
                    if isSearch {
                        self.searchResults = result.results
                    } else {
                        self.searchResults = []
                        if result.page == 1 {
                            self.list = result.results
                        } else {
                            self.list = self.list + result.results
                        }
                        self.page = result.page
                        self.totalPages = result.totalPages
                    }
                    self.error = nil
                } catch {
                    self.error = error.localizedDescription
                }
            }
        }
    }
}



struct CrumbSelection: View {
    @Binding private var selectedTitleIndex: Int?
    private var transition: AnyTransition
    private var titles: [String]?
    private var labels: [Label<Text, Image>]?
    
    init(selectedTitleIndex: Binding<Int?>, titles: [String], transition: AnyTransition = .scale.combined(with: .opacity)) {
        self._selectedTitleIndex = selectedTitleIndex
        self.titles = titles
        self.transition = transition
    }
    
    init(selectedTitleIndex: Binding<Int?>, labels: [Label<Text, Image>], transition: AnyTransition = .scale.combined(with: .opacity)) {
        self._selectedTitleIndex = selectedTitleIndex
        self.labels = labels
        self.transition = transition
    }
    
    var body: some View {
        let count = titles != nil ? titles!.count : labels!.count
        
        Group {
            HStack(spacing: 8) {
                if selectedTitleIndex != nil {
                    Button {
                        selectedTitleIndex = nil
                    } label: {
                        Image(systemName: "xmark")
                            .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .overlay {
                                Circle()
                                    .stroke(.tertiary, lineWidth: 1)
                            }
                    }
                    .transition(transition)
                }
                
                ForEach(0..<count, id: \.self) { index in
                    Button {
                        if selectedTitleIndex == index {
                            selectedTitleIndex = nil
                        } else {
                            selectedTitleIndex = index
                        }
                    } label: {
                        if let titles = titles {
                            Text(titles[index])
                                .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.tertiary.opacity(selectedTitleIndex == index ? 1 : 0))
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.tertiary, lineWidth: 1)
                                }
                        } else {
                            labels![index]
                        }
                    }
                }
                .transition(.move(edge: .top))
            }
            .fixedSize()
            .frame(height: 35)
            .animation(.easeInOut(duration: 0.3), value: selectedTitleIndex)
        }
    }
    
    
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ListView(viewModel: ListView.ViewModel(mediaService: RealMediaService(movieRepository: RealMediaRepository())))
        }
    }
}
