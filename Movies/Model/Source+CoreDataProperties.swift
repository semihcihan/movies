//
//  Source+CoreDataProperties.swift
//  Movies
//
//  Created by Semih Cihan on 20.04.2023.
//
//

import Foundation
import CoreData


extension Source {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Source> {
        return NSFetchRequest<Source>(entityName: "Source")
    }

    @NSManaged public var original: String?
    @NSManaged public var large2x: String?
    @NSManaged public var large: String?
    @NSManaged public var medium: String?
    @NSManaged public var small: String?
    @NSManaged public var portrait: String?
    @NSManaged public var landscape: String?
    @NSManaged public var tiny: String?

}

extension Source : Identifiable {

}
