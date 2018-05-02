//
//  Entry+CoreDataProperties.swift
//  Notebook
//
//  Created by Garrett Votaw on 5/1/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        let request = NSFetchRequest<Entry>(entityName: "Entry")
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return request
    }

    @NSManaged public var title: String
    @NSManaged public var text: String
    @NSManaged public var photo: Data?
    @NSManaged public var creationDate: NSDate

}

// MARK: Generated accessors for tags
extension Entry {
    
}
