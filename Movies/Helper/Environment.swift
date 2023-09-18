//
//  Environment.swift
//  Movies
//
//  Created by Semih Cihan on 16.06.2023.
//

import Foundation
import SwiftUI

private struct NavigationKey: EnvironmentKey {
    static let defaultValue = NavigationPath()
}

extension EnvironmentValues {
    var path: NavigationPath {
        get { self[NavigationKey.self] }
        set { self[NavigationKey.self] = newValue }
    }
}

// extension View {
//    func path(_ myCustomValue: NavigationPath) -> some View {
//        environment(\.path, myCustomValue)
//    }
// }
