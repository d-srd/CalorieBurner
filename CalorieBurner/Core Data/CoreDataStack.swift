//
//  CoreDataStack.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 05/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    init(container: NSPersistentContainer) {
        persistentContainer = container
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    convenience init() {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        self.init(container: container)
    }
    
    let persistentContainer: NSPersistentContainer
    lazy var viewContext = persistentContainer.viewContext
    lazy var backgroundContext = persistentContainer.newBackgroundContext()
        
    func fetchOrCreate(at day: Date) throws -> Daily {
        let request = Daily.fetchRequest(in: day)
        
        do {
            guard let daily = try viewContext.fetch(request).first else {
                return Daily(context: viewContext, date: day)
            }
            
            return daily
        } catch {
            throw error
        }
        
    }
    
    /// If a Daily does not exist in the specified date, it is created with the provided values. Otherwise, it is updated with the provided values. Pass nil to not update a single value.
    func updateOrCreate(at day: Date, mass: Mass?, energy: Energy?) throws -> Daily {
        let request = Daily.fetchRequest(in: day)
        
        do {
            if let daily = try viewContext.fetch(request).first {
                if mass != nil {
                    daily.mass = mass!
                }
                if energy != nil {
                    daily.energy = energy!
                }
                try viewContext.save()
                
                return daily
            } else {
                let daily = Daily(context: viewContext, date: day)
                daily.mass = mass
                daily.energy = energy
                
                viewContext.insert(daily)
                try viewContext.save()
                
                return daily
            }
        } catch {
            throw error
        }
    }
    
    func fetchAll() throws -> [Daily] {
        let request = Daily.tableFetchRequest()
        
        do {
            return try viewContext.fetch(request)
        } catch {
            throw error
        }
    }
    
    func remove(with objectID: NSManagedObjectID) {
        let daily = viewContext.object(with: objectID)
        viewContext.delete(daily)
    }
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving background context: \(error)")
            }
        }
    }
}
