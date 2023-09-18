//
//  Path.swift
//  Movies
//
//  Created by Semih Cihan on 21.06.2023.
//

import Foundation
import SwiftUI

class Navigation: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()

    enum Destination: String {
        case scan
        case info
    }
}
