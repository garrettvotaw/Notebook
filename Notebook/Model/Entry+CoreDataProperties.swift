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
import UIKit


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
    @NSManaged public var creationDate: Date

}


extension Entry {
    @nonobjc class func with(title: String, text: String, photo: UIImage?, in context: NSManagedObjectContext) -> Entry {
        let entry = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: context) as! Entry
        
        entry.title = title
        entry.text = text
        entry.creationDate = Date()
        if let photo = photo {
            entry.photo = UIImageJPEGRepresentation(photo, 1.0)
            return entry
        }
        return entry
    }
    
    var image: UIImage? {
        guard let photoData = self.photo else {return nil}
        return UIImage(data: photoData)
    }
}
