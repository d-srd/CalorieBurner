//
//  Daily.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 25/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import CoreData

typealias Mass = Measurement<UnitMass>
typealias Energy = Measurement<UnitEnergy>

/// Representation of a single day containing a mass and an energy
class Daily: NSManagedObject {
    public class func makeFetchRequest() -> NSFetchRequest<Daily> {
        return NSFetchRequest<Daily>(entityName: "Daily")
    }
    
    public class func fetchRequest(in date: Date) -> NSFetchRequest<Daily> {
        let request = NSFetchRequest<Daily>(entityName: "Daily")
        request.predicate = isInSameDayPredicate(as: date)
        
        return request
    }
    
    public class func tableFetchRequest() -> NSFetchRequest<Daily> {
        let request = NSFetchRequest<Daily>(entityName: "Daily")
        request.sortDescriptors = [NSSortDescriptor(key: "year", ascending: false), NSSortDescriptor(key: "month", ascending: false), NSSortDescriptor(key: "day", ascending: false)]
        
        return request
    }
    
    static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        
        return fmt
    }()
    
    public class func isInSameDayPredicate(as date: Date) -> NSPredicate {
        let newYear = Calendar.current.component(.year, from: date)
        let newMonth = Calendar.current.component(.month, from: date)
        let newDay = Calendar.current.component(.day, from: date)
        
        return NSPredicate(format: "year == %@ AND month == %@ AND day == %@", argumentArray: [newYear, newMonth, newDay])
    }
    
    public var created: Date {
        get {
            let dateString = "\(year)-\(month)-\(day)"
            return Daily.dateFormatter.date(from: dateString)!
        }
        set {
            let newYear = Calendar.current.component(.year, from: newValue)
            let newMonth = Calendar.current.component(.month, from: newValue)
            let newDay = Calendar.current.component(.day, from: newValue)
//            let newDate = Calendar.current.dateComponents([.year, .month, .day], from: newValue)
            year = Int16(newYear)
            month = Int16(newMonth)
            day = Int16(newDay)
            
            print("\(year)-\(month)-\(day)")
        }
    }
    
    convenience init(context: NSManagedObjectContext, date: Date) {
        self.init(context: context)
        created = date
    }
}
