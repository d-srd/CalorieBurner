//
//  CoreDataTests.swift
//  CalorieBurnerTests
//
//  Created by Dino Srdoč on 31/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import XCTest
import CoreData
@testable import CalorieBurner

class CoreDataTests: XCTestCase {
    private var stack: CoreDataStack!
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))])
        return model!
    }()
    
    lazy var mockPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MockDiaryContainer", managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            guard description.type == NSInMemoryStoreType, error == nil else {
                fatalError("Error: \(error!)")
            }
        }
        
        return container
    }()
    
    func makeStubs() {
        func insertDaily(date: Date, mass: Double, energy: Double) -> Daily? {
            let daily = NSEntityDescription.insertNewObject(forEntityName: "Daily", into: mockPersistentContainer.viewContext)
            
            let massValue = NSDecimalNumber(value: mass)
            let energyValue = NSDecimalNumber(value: energy)
            daily.setValue(date, forKey: "created")
            daily.setValue(massValue, forKey: "massValue")
            daily.setValue(energyValue, forKey: "energyValue")
            
            return daily as? Daily
        }
        
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        
        let dateStrings = ["2018-01-01", "2018-01-02", "2018-01-03", "2018-01-04", "2018-01-05", "2018-01-06", "2018-01-07"]
        let dates = dateStrings.compactMap(fmt.date)
        let masses: [Double] = [100, 95, 90, 85, 80, 75, 70]
        let energies: [Double] = [3200, 3100, 3000, 2900, 2800, 2700, 2600]
        
        for (index, date) in dates.enumerated() {
            insertDaily(date: date, mass: masses[index], energy: energies[index])
        }
        
        do {
            try mockPersistentContainer.viewContext.save()
        } catch {
            print("error saving: \(error)")
        }
    }
    
    func flushData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Daily")
        let dailies = try! mockPersistentContainer.viewContext.fetch(fetchRequest)
        
        for case let daily as Daily in dailies {
            mockPersistentContainer.viewContext.delete(daily)
        }
        
        try! mockPersistentContainer.viewContext.save()
    }
    
    override func setUp() {
        super.setUp()
        
        makeStubs()
        stack = CoreDataStack(container: mockPersistentContainer)
    }
    
    override func tearDown() {
        flushData()
        super.tearDown()
    }
    
    func testFetchAll() {
        // given default stubs
        let stubs = try! stack.fetchAll()
        
        // we should get 7 dailies
        XCTAssertEqual(stubs.count, 7, "7 default stubs")
    }
    
    func testRemoveObject() {
        let stubs = try! stack.fetchAll()
        let stub = stubs[0]
        
        let numberOfItems = stubs.count
        stack.remove(with: stub.objectID)
        stack.save()
        
        XCTAssertEqual(numberOfItemsInPersistentStore(), numberOfItems - 1, "We should have 6 stubs now")
    }
    
    func numberOfItemsInPersistentStore() -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Daily")
        let dailies = try! mockPersistentContainer.viewContext.fetch(request)
        return dailies.count
    }
}
