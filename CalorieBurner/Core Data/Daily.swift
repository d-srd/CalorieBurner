//
//  Daily.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 25/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import CoreData

@objc public enum Feelings: Int {
    case bad, dissatisfied, neutral, satisfied, happy
}

/// Representation of a single day containing a mass and an energy
class Daily: NSManagedObject {
    
    // a hack to get around the fact that we can't store optional enums in Core Data
    public var mood: Feelings? {
        get {
            return (moodID?.intValue).flatMap(Feelings.init)
        } set {
            moodID = (newValue?.rawValue).flatMap(NSNumber.init)
        }
    }
    
    private var massValue: Double? {
        return mass?.value
    }
    
    
    private var energyValue: Double? {
        return energy?.value
    }
    
    /// Default fetch request, wrapping an NSFetchRequest call
    public class func makeFetchRequest() -> NSFetchRequest<Daily> {
        return NSFetchRequest<Daily>(entityName: "Daily")
    }
    
    /// Filter objects by day
    public class func fetchRequest(in date: Date) -> NSFetchRequest<Daily> {
        let request = NSFetchRequest<Daily>(entityName: "Daily")
        request.predicate = isInSameDayPredicate(as: date)
        
        return request
    }
    
    // Filter objects by a range of dates
    public class func fetchRequest(in dateRange: (start: Date, end: Date)) -> NSFetchRequest<Daily> {
        let request = NSFetchRequest<Daily>(entityName: "Daily")
        request.predicate = NSPredicate(
            format: "created >= %@ AND created <= %@",
            argumentArray: [dateRange.start.startOfDay, dateRange.end.endOfDay]
        )
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        
        return request
    }
    
    /// A sorted list of all entries
    public class func tableFetchRequest() -> NSFetchRequest<Daily> {
        let request = NSFetchRequest<Daily>(entityName: "Daily")
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        
        return request
    }
    
    static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "YYYY-MM-dd"
        
        return fmt
    }()
    
    public class func isInSameDayPredicate(as date: Date) -> NSPredicate {
        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay
        
        return NSPredicate(
            format: "created >= %@ AND created <= %@",
            argumentArray: [startOfDay, endOfDay]
        )
    }
    
    public class func isInDateBetweenPredicate(start: Date, end: Date) -> NSPredicate {
        let startDate = start.startOfDay
        let endDate = end.endOfDay
        
        return NSPredicate(
            format: "created >= %@ AND created <= %@",
            argumentArray: [startDate, endDate]
        )
    }
    
    convenience init(context: NSManagedObjectContext, date: Date) {
        self.init(context: context)
        created = date
    }
    
    public func updateValues(mass newMass: Double?, energy newEnergy: Double?) {
        mass = newMass.flatMap { Mass(value: $0, unit: .kilograms) } ?? mass
        energy = newEnergy.flatMap { Energy(value: $0, unit: .kilocalories) } ?? energy
    }
    
    public static var dateSortDescriptor = NSSortDescriptor(key: "created", ascending: false)
}
