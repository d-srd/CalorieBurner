//
//  DailyFetchedResultsController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 02/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation
import CoreData

class DailyFetchedResultsController {
    private var fetchRequest: NSFetchRequest<Daily>
    private var managedObjectContext: NSManagedObjectContext
    private let startingDate: Date
    private let endingDate: Date
    
    private var objects: [Daily]?
    private var objectCache = [IndexPath : Daily]()
    private var dateCache = [Date : IndexPath]()
    
    // used only for the function to get date from indexpath
    
    private var inverseDateCache = [IndexPath : Date]()
    
    private let prettyDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .long
        
        return fmt
    }()
    
    lazy var numberOfSections = Calendar.current.dateComponents([.day], from: startingDate, to: endingDate).day!
    
    init(
        fetchRequest: NSFetchRequest<Daily>,
        managedObjectContext: NSManagedObjectContext,
        dateBounds: (start: Date, end: Date))
    {
        self.fetchRequest = fetchRequest
        self.managedObjectContext = managedObjectContext
        self.startingDate = dateBounds.start
        self.endingDate = dateBounds.end
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextDidChange),
            name: .NSManagedObjectContextObjectsDidChange,
            object: self.managedObjectContext
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .NSManagedObjectContextObjectsDidChange,
            object: managedObjectContext
        )
    }
    
    @objc private func managedObjectContextDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<Daily>,
            inserts.count > 0
        {
            for object in inserts {
                cache(object)
            }
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<Daily>,
            updates.count > 0
        {
            for object in updates {
                cache(object)
            }
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<Daily>,
            deletes.count > 0
        {
            for object in deletes {
                guard let indexPath = dateCache[object.created!] else {
                    continue
                }
                objectCache[indexPath] = nil
                dateCache[object.created!] = nil
                inverseDateCache[indexPath] = nil
            }
        }
    }
    
    func performFetch() throws {
        do {
            objects = try managedObjectContext.fetch(fetchRequest)
            for object in objects! {
                cache(object)
            }
        } catch {
            throw error
        }
    }
    
    private func cache(_ object: Daily) {
        guard let _indexPath = indexPath(for: object.created!) else {
            return
        }
        dateCache[object.created!] = _indexPath
        inverseDateCache[_indexPath] = object.created
        objectCache[_indexPath] = object
    }
    
    func indexPath(for date: Date) -> IndexPath? {
        guard date >= startingDate &&  date <= endingDate else {
            return nil
        }
        
        guard let indexPath = dateCache[date] else {
            let dayComponent = Calendar.current.dateComponents([.day], from: startingDate, to: date).day!
            
            return IndexPath(row: dayComponent, section: 0)
        }
        
        return indexPath
    }
    
    func object(at indexPath: IndexPath) -> Daily? {
        return objectCache[indexPath]
    }
    
    func indexPath(for object: Daily) -> IndexPath? {
        assert(
            startingDate <= object.created! && object.created! <= endingDate,
            "Invalid date bounds set")
        guard let indexPath = dateCache[object.created!] else {
            return nil
        }
        
        return indexPath
    }
    
    
    // TODO: - move this out of here
    func date(for indexPath: IndexPath) -> Date? {
        let d = Calendar.current.date(byAdding: .day, value: indexPath.row, to: startingDate)
        return d
    }
    
    func titleForSection(_ section: Int) -> String? {
        let date = Calendar.current.date(byAdding: .day, value: section, to: startingDate)!
        
        return prettyDateFormatter.string(from: date)
    }
}
