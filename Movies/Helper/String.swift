//
//  String.swift
//  Movies
//
//  Created by Semih Cihan on 22.06.2023.
//

import Foundation

extension StringProtocol {
    var capitalizedSentence: String {
        let firstLetter = self.prefix(1).capitalized
        let remainingLetters = self.dropFirst().lowercased()
        return firstLetter + remainingLetters
    }
}
