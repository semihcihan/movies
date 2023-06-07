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
                        MediaDetailView(media: movie)
                    }
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
    @MainActor
    class ViewModel: ObservableObject {
        @Published var list: [Media]
        @Published var searchResults: [Media]
        @Published var error: String?
        @Published var paths: [Media] = []
        @Published var selectedMediaIndex: Int?
        @Published var searchText: String
        @Published var selectedRatingIndex: Int?
        
        let ratings: [Int] = [6, 7, 8, 9]
        let service: MediaService
        
        var selectedRating: Int?
        var mediaType: Media.MediaType?
        var page: Int = 0
        var totalPages: Int = 1
        var cancellable: AnyCancellable?
        var selectedMediaCancellable: AnyCancellable?
        var searchCancellable: AnyCancellable?
        var selectedRatingCancellable: AnyCancellable?
        
        init(list: [Media] = [], error: String? = nil, searchResults: [Media] = [], searchText: String = "", service: MediaService = DIContainer.shared.resolve(type: MediaService.self)) {
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
            Task {
                let isSearch = searchText.count > 0
                guard isSearch || canRequestMore else {
                    return
                }
                
                do {
                    let result = try await service.list(
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
                                        .fill(selectedTitleIndex == index ? .gray : .white)
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
            .animation(.easeInOut(duration: 0.6), value: selectedTitleIndex)
        }
    }
    
    
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(viewModel: ListView.ViewModel(service: RealMediaService(movieRepository: RealMediaRepository())))
    }
}
