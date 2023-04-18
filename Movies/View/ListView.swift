//
//  ListView.swift
//  Movies
//
//  Created by Semih Cihan on 17.04.2023.
//

import SwiftUI

struct ListView: View {
    @StateObject var viewModel: ListViewModel = ListViewModel()
    
    var body: some View {
        List(viewModel.list?.photos ?? []) { photo in
            PhotoCellView(photo: photo)
        }
        .task {
            viewModel.fetch()
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
