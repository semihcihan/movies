//
//  MoviesApp.swift
//  Movies
//
//  Created by Semih Cihan on 17.04.2023.
//

import SwiftUI

@main
struct MoviesApp: App {

    init() {
        DIContainer.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }
}
