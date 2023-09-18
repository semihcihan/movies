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
    @EnvironmentObject var navigation: Navigation

    @ViewBuilder
    var headerView: some View {
        if viewModel.searchText.count == 0 {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .frame(width: 20)
                    CrumbSelection(selectedTitleIndex: $viewModel.selectedRatingIndex, titles: viewModel.ratings.map { String($0) + "+" })
                    Spacer()
                }
                HStack {
                    Image(systemName: "play.fill")
                        .frame(width: 20)
                    CrumbSelection(selectedTitleIndex: $viewModel.selectedMediaIndex, titles: ["Movie", "TV"])
                    Spacer()
                }
            }
            .padding(.bottom, 12)
            .padding(.top, -12)
        }
    }

    @ViewBuilder
    var errorView: some View {
        if let error = viewModel.error {
            Button {
                viewModel.fetch()
            } label: {
                Text("\(error.capitalizedSentence)\nPlease try again.")
                    .foregroundColor(.secondary)
                    .padding(20)
            }
        }
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            List {
                Section {
                    if viewModel.error != nil {
                        EmptyView()
                    } else if !viewModel.loadingFirstPage {
                        ForEach(viewModel.list, id: \.id) { media in
                            switch media {
                                case .movie, .tv:
                                    NavigationLink(value: media) {
                                        MediaCellView(media: media)
                                    }
                                    .onTapGesture {
                                        navigation.path.append(media)
                                    }
                                default:
                                    MediaCellView(media: media)
                            }
                        }

                        if viewModel.canRequestMore {
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
                    } else {
                        ForEach(0...5, id: \.self) { _ in
                            MediaCellView(media: nil)
                        }
                    }
                } header: {
                    headerView
                }
            }
            .overlay {
                errorView
            }
            .refreshable(action: {
                viewModel.fetch(forceInitialPage: true)
            })
            .searchable(text: $viewModel.searchText)
            .autocorrectionDisabled()
            .listStyle(.grouped)
            .onSubmit(of: .search) {
                viewModel.fetch(forceInitialPage: true)
            }
            .navigationDestination(for: Media.self) { movie in
                MediaDetailView(media: movie)
            }
            .navigationDestination(for: Navigation.Destination.self, destination: { dest in
                switch dest {
                    case .scan:
                        ScannerViewControllerRepresentable()
                            .edgesIgnoringSafeArea([.bottom])
                    case .info:
                        InfoView()
                }
            })
            .toolbar {
                if MyDataScannerViewController.isSupported {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            navigation.path.append(Navigation.Destination.scan)
                        } label: {
                            Image(systemName: "camera.fill")
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        navigation.path.append(Navigation.Destination.info)
                    } label: {
                        Text(Image(systemName: "info.square"))
                            .font(.footnote)
                    }
                }

            }
            .navigationBarTitle("Movie Vision", displayMode: .large)
        }
        .onAppear {
            viewModel.fetch()
        }
    }
}

extension ListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var list: [Media]
        @Published var error: String?
        @Published var selectedMediaIndex: Int?
        @Published var searchText: String
        @Published var selectedRatingIndex: Int?
        @Published var selectedCategoryIndex: Int?
        @Published var loadingFirstPage: Bool = true

        let ratings: [Int] = [5, 6, 7, 8]
        let mediaService: MediaService
        let genreService: GenreService

        var selectedRating: Int?
        var mediaType: Media.MediaType?
        var page: Int = 0
        var totalPages: Int = 1

        init(list: [Media] = [],
             error: String? = nil,
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
                    self.fetch(forceInitialPage: true)
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
                    self.fetch(forceInitialPage: true)
                }
            }

            Task { [weak self] in
                guard let self = self else {
                    return
                }
                for await val in self.$searchText.values.dropFirst() where val.isEmpty {
                    fetch(forceInitialPage: true)
                }
            }
        }

        var canRequestMore: Bool {
            return totalPages > page
        }

        func fetch(forceInitialPage: Bool = false) {
            Task {
                if forceInitialPage {
                    page = 0
                }
                guard canRequestMore else {
                    return
                }
                self.error = nil

                do {
                    let task = Task {
                        if page == 0 { // data on screen is old
                            if !list.isEmpty { // if empty, show redacted without wait
                                try? await Task.sleep(for: .seconds(0.5))
                            }
                            if !Task.isCancelled {
                                loadingFirstPage = true
                            }
                        }
                    }

                    let result = try await mediaService.list(
                        page: page + 1,
                        mediaType: mediaType,
                        search: searchText,
                        rating: selectedRating)
                    if result.page == 1 {
                        list = result.results
                    } else {
                        list += result.results
                    }
                    page = result.page
                    totalPages = result.totalPages
                    error = nil

                    task.cancel()
                    Task {
                        try? await Task.sleep(for: .seconds(1))
                        loadingFirstPage = false
                    }
                } catch {
                    self.error = error.localizedDescription
                }
            }
        }
    }
}

struct CrumbSelection: View {
    @Binding private var selectedTitleIndex: Int?
    private var transition: AnyTransition = .scale.combined(with: .opacity)
    private var titles: [String]?
    private var labels: [Label<Text, Image>]?

    init(selectedTitleIndex: Binding<Int?>, titles: [String]) {
        self._selectedTitleIndex = selectedTitleIndex
        self.titles = titles
    }

    init(selectedTitleIndex: Binding<Int?>, labels: [Label<Text, Image>]) {
        self._selectedTitleIndex = selectedTitleIndex
        self.labels = labels
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
                                .foregroundColor(selectedTitleIndex == index ? .white : .accentColor)
                                .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.primary.opacity(selectedTitleIndex == index ? 1 : 0))
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
            ListView(viewModel: ListView.ViewModel(mediaService: MockMediaService()))
        }
        .environmentObject(Navigation())
    }
}
