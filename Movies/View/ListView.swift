//
//  ListView.swift
//  Movies
//
//  Created by Semih Cihan on 17.04.2023.
//

import SwiftUI

struct ListView: View {
    @StateObject var viewModel: ListViewModel = ListViewModel()
    
    let columns = [
        GridItem(.adaptive(minimum: 400), spacing: 5)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(viewModel.list?.photos ?? []) { photo in
                        NavigationLink(destination: PhotoView(photo: photo)) {
                            PhotoCellView(photo: photo)
                        }
                    }
                    if viewModel.canRequestMore {
                        ProgressView()
                            .padding()
                            .onAppear {
                                viewModel.fetch()
                            }
                    }
                }
                .padding(5)
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
