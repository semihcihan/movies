//
//  SourceCD+CoreDataProperties.swift
//  Movies
//
//  Created by Semih Cihan on 20.04.2023.
//
//

import Foundation
import CoreData


extension SourceCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SourceCD> {
        return NSFetchRequest<SourceCD>(entityName: "SourceCD")
    }

    @NSManaged public var original: String?

}

extension SourceCD : Identifiable {

}
