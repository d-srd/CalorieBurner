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
    
    lazy var persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    lazy var viewContext = persistentContainer.viewContext
    
    private init() { }
    
    func getOrCreate(at day: Date) throws -> Daily {
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
    
    func updateOrCreate(at day: Date, mass: Mass?, energy: Energy?) throws -> Daily {
        let request = Daily.fetchRequest(in: day)
        
        do {
            if let daily = try viewContext.fetch(request).first {
                if mass != nil { daily.mass = mass }
                if energy != nil { daily.energy = energy }
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
}
