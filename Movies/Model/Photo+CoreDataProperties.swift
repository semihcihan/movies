//
//  Photo+CoreDataProperties.swift
//  Movies
//
//  Created by Semih Cihan on 20.04.2023.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var id: Int64
    @NSManaged public var width: Int64
    @NSManaged public var height: Int64
    @NSManaged public var url: String?
    @NSManaged public var photographer: String?
    @NSManaged public var photographerUrl: String?
    @NSManaged public var photographerId: Int64
    @NSManaged public var avgColor: String?
    @NSManaged public var liked: Bool
    @NSManaged public var alt: String?
    @NSManaged public var attribute: String?
    @NSManaged public var attribute1: String?
    @NSManaged public var src: Source?

}

extension Photo : Identifiable {

}
