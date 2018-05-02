//
//  CoreDataStack.swift
//  Notebook
//
//  Created by Garrett Votaw on 5/1/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let container = self.persistentContainer
        return container.viewContext
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Notebook")
        container.loadPersistentStores() { storeDescription, error in
            if let error = error {
                fatalError("Unresolved error: \(error)")
            }
        }
        return container
    }()
    
}


extension NSManagedObjectContext {
    func saveChanges() throws {
        if self.hasChanges {
            try save()
        }
    }
}
