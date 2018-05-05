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
        fakeEntry = Entry.with(title: "Test", text: "Test", photo: nil, location: nil, in: managedObjectContext)
        XCTAssert(fakeEntry != nil)
    }
    
    func testDeleteEntry() {
        guard let fakeEntry = fakeEntry else {return}
        let id = fakeEntry.objectID
        managedObjectContext.delete(fakeEntry)
        do {
            try managedObjectContext.saveChanges()
        } catch {
            print("changes not saved")
        }
        
        let entry: NSManagedObject? = managedObjectContext.object(with: id)
        XCTAssert(entry == nil)
    }
    
    func testEditEntry() {
        fakeEntry = Entry.with(title: "Edited", text: "Edit Test", photo: nil, location: nil, in: managedObjectContext)
        do {
            try managedObjectContext.saveChanges()
        } catch {
            print(error)
        }
        
        fakeEntry?.title = "edit"
        
        do {
            try managedObjectContext.saveChanges()
        } catch {
            print(error)
        }
        
        XCTAssert(fakeEntry?.title == "edit")
    }
    
    
    func testDateAttachedToEntry() {
        fakeEntry = Entry.with(title: "Test", text: "Date Test", photo: nil, location: nil, in: managedObjectContext)
        do {
            try managedObjectContext.saveChanges()
        } catch {
            print(error)
        }
        
        XCTAssert(fakeEntry?.creationDate != nil)
    }
    
    
}
