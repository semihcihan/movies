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
        NavigationStack(path: $viewModel.paths) {
            if viewModel.list.count > 0 {
                    List {
                        Section {
                            ForEach(viewModel.searchText.count > 0 ? viewModel.searchResults : viewModel.list, id: \.id) { media in
                                
                                switch media {
                                    case .movie(_), .tv(_):
                                        NavigationLink(value: media) {
                                            MovieCellView(media: media)
                                        }
                                    default:
                                        MovieCellView(media: media)
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
                                        Image(systemName: "play.fill")
                                            .frame(width: 20)
                                        CrumbSelection(selectedTitleIndex: $viewModel.selectedMediaIndex, titles: ["Movie", "TV"])
                                        Spacer()
                                    }
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .frame(width: 20)
                                        CrumbSelection(selectedTitleIndex: $viewModel.selectedRatingIndex, titles: viewModel.ratings.map{ String($0) + "+" } )
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
                        MovieDetailView(media: movie)
                    }
            } else {
                List {
                    MovieCellView(media: nil)
                    MovieCellView(media: nil)
                    MovieCellView(media: nil)
                    MovieCellView(media: nil)
                    MovieCellView(media: nil)
                }
                .onAppear {
                    viewModel.fetch()
                }
            }
        }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @FocusState private var focused: Bool
    let textFieldTransition: AnyTransition = .move(edge: .trailing).combined(with: .opacity)
    let magnifyTransition: AnyTransition = .opacity
    
    var body: some View {
        HStack {
            if !isSearching {
                Group {
                    Spacer()
                    Button {
                        isSearching.toggle()
                        focused.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .transition(magnifyTransition)
                }
                
            } else {
                Group {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Search", text: $searchText)
                            .focused($focused)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray4))
                    }
                    
                    Button {
                        isSearching.toggle()
                        focused.toggle()
                    } label: {
                        Text("Cancel")
                            .textCase(nil)
                    }
                }
                .transition(textFieldTransition)
            }
        }
        .frame(height: 30)
    }
}

extension ListView {
    class ViewModel: ObservableObject {
        @Published var list: [Media]
        @Published var searchResults: [Media]
        @Published var error: String?
        @Published var paths: [Media] = []
        @Published var selectedMediaIndex: Int?
        @Published var searchText: String
        @Published var selectedRatingIndex: Int?
        
        let ratings: [Int] = [6, 7, 8, 9]
        let service: MovieService
        
        var selectedRating: Int?
        var mediaType: Media.MediaType?
        var page: Int = 0
        var totalPages: Int = 1
        var cancellable: AnyCancellable?
        var selectedMediaCancellable: AnyCancellable?
        var searchCancellable: AnyCancellable?
        var selectedRatingCancellable: AnyCancellable?
        
        init(list: [Media] = [], error: String? = nil, searchResults: [Media] = [], searchText: String = "", service: MovieService = DIContainer.shared.resolve(type: MovieService.self)) {
            self.error = error
            self.list = list
            self.service = service
            self.searchText = searchText
            self.searchResults = searchResults
            
            selectedMediaCancellable = $selectedMediaIndex.dropFirst(1).sink { [weak self] index in
                switch index {
                    case 0:
                        self?.mediaType = .movie
                    case 1:
                        self?.mediaType = .tv
                    default:
                        self?.mediaType = nil
                }
                self?.page = 0
                self?.totalPages = 1
                self?.fetch()
            }
            
            selectedRatingCancellable = $selectedRatingIndex.dropFirst(1).sink { [weak self] index in
                if let index = index {
                    self?.selectedRating = self?.ratings[index]
                } else {
                    self?.selectedRating = nil
                }
                self?.page = 0
                self?.totalPages = 1
                self?.fetch()
            }
            
            searchCancellable = $searchText.sink(receiveValue: { [weak self] val in
                if val.count == 0 {
                    self?.searchResults = []
                }
            })
        }
        
        var canRequestMore: Bool {
            return totalPages > page
        }
        
        func fetch() {
            let isSearch = searchText.count > 0
            guard isSearch || canRequestMore else {
                return
            }
                        
            cancellable = service.list(
                page: searchText.count > 0 ? 1 : page + 1,
                mediaType: mediaType,
                search: searchText,
                rating: selectedRating)
                .sink(receiveCompletion: { [weak self] failure in
                    switch failure {
                        case .failure(let err):
                            self?.error = err.localizedDescription
                        default:
                            break
                    }
                }, receiveValue: { [weak self] output in
                    if isSearch {
                        self?.searchResults = output.results
                    } else {
                        self?.searchResults = []
                        if output.page == 1 {
                            self?.list = output.results
                        } else {
                            self?.list = (self?.list ?? []) + output.results
                        }
                        self?.page = output.page
                        self?.totalPages = output.totalPages
                    }
                    self?.error = nil
                })
        }
    }
}



struct CrumbSelection: View {
    @Binding var selectedTitleIndex: Int?
    let transition: AnyTransition = .scale.combined(with: .opacity)
    var titles: [String]
    
    init(selectedTitleIndex: Binding<Int?>, titles: [String]) {
        self._selectedTitleIndex = selectedTitleIndex
        self.titles = titles
    }
    
    var body: some View {
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
                
                ForEach(0..<titles.count, id: \.self) { index in
                    Button {
                        if selectedTitleIndex == index {
                            selectedTitleIndex = nil
                        } else {
                            selectedTitleIndex = index
                        }
                    } label: {
                        Text(titles[index])
                            .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedTitleIndex == index ? .gray : .white)
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.tertiary, lineWidth: 1)
                            }
                    }
                }
                .transition(.move(edge: .top))
            }
            .fixedSize()
            .frame(height: 35)
            .animation(.easeInOut(duration: 0.6), value: selectedTitleIndex)
        }
    }
    
    
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(viewModel: ListView.ViewModel(service: RealMovieService(movieRepository: RealMovieRepository())))
    }
}
