//
//  NotebookTests.swift
//  NotebookTests
//
//  Created by Garrett Votaw on 4/26/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import XCTest
import CoreData
@testable import Notebook

class NotebookTests: XCTestCase {
    
    var persistentStore: NSPersistentStore!
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!

    var fakeEntry: Entry?
    
    let editEntryController: EditEntryViewController = EditEntryViewController()
    
    override func setUp() {
        super.setUp()
        
        managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            try persistentStore = storeCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator =  storeCoordinator
        } catch {
            print("Error occured Setting up Core Data")
        }
        
        editEntryController.context = managedObjectContext
        
        editEntryController.saveEntry(nil, title: "Title", text: "Test Text")
        let request: NSFetchRequest<Entry> = NSFetchRequest(entityName: "Entry")
        fakeEntry = try! managedObjectContext.fetch(request).first!
    }
    
    override func tearDown() {
        persistentStore = nil
        storeCoordinator = nil
        managedObjectContext = nil
        managedObjectModel = nil
        fakeEntry = nil
        
        super.tearDown()
    }
    
    func testCreateEntry() {
        XCTAssert(fakeEntry != nil, "Entry is nil")
    }
    
}
