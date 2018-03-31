//
//  Daily.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 25/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import CoreData

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        let components = DateComponents(day: 1, second: -1)
        return Calendar.current.date(byAdding: components, to: self)!
    }
}

typealias Mass = Measurement<UnitMass>
typealias Energy = Measurement<UnitEnergy>

/// Representation of a single day containing a mass and an energy
@objc(Daily)
public class Daily: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Daily> {
        return NSFetchRequest<Daily>(entityName: "Daily")
    }
    
    @NSManaged public var created: Date?
    @NSManaged public var massValue: NSDecimalNumber?
    @NSManaged public var energyValue: NSDecimalNumber?
    @NSManaged public var isFromHealthKit: Bool
    
    public class func makeFetchRequest() -> NSFetchRequest<Daily> {
        return NSFetchRequest<Daily>(entityName: "Daily")
    }
    
    public class func fetchRequest(in date: Date) -> NSFetchRequest<Daily> {
        let request = NSFetchRequest<Daily>(entityName: "Daily")
        request.predicate = isInSameDayPredicate(as: date)
        
        return request
    }
    
    public class func fetchRequest(in dateRange: (start: Date, end: Date)) -> NSFetchRequest<Daily> {
        let request = NSFetchRequest<Daily>(entityName: "Daily")
        request.predicate = NSPredicate(
            format: "created >= %@ AND created <= %@",
            argumentArray: [dateRange.start.startOfDay, dateRange.end.endOfDay]
        )
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        
        return request
    }
    
    public class func dictionaryFetchRequest(
        in dateRange: (start: Date, end: Date),
        properties: [String]
        ) -> NSFetchRequest<NSDictionary>
    {
        let request = NSFetchRequest<NSDictionary>(entityName: "Daily")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = properties
        request.predicate = isInDateBetweenPredicate(start: dateRange.start, end: dateRange.end)
        
        return request
    }
    
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
    
    var mass: Mass? {
        get {
            if let massValue = massValue {
                return Mass(value: massValue.doubleValue, unit: .kilograms)
            }
            return nil
        }
        set {
            if let mass = newValue {
                massValue =  NSDecimalNumber(value: mass.converted(to: .kilograms).value)
            } else {
                massValue = nil
            }
        }
    }
    
    var energy: Energy? {
        get {
            if let energyValue = energyValue {
                return Energy(value: energyValue.doubleValue, unit: .kilocalories)
            }
            return nil
        }
        set {
            if let energy = newValue {
                energyValue = NSDecimalNumber(value:  energy.converted(to: .kilocalories).value)
            } else {
                energyValue = nil
            }
        }
    }
    
    public static let massExpressionKey = "massValue"
    public static var massExpression = NSExpression(forKeyPath: massExpressionKey)
    public static let averageMassKey = "avgMass"
    
    public static let energyExpressionKey = "energyValue"
    public static var energyExpression = NSExpression(forKeyPath: energyExpressionKey)
    public static let totalEnergyKey = "sumEnergy"
    
    public static var averageMassDescription: NSExpressionDescription = {
        let description = NSExpressionDescription()
        let avgExpression = NSExpression(forFunction: "average:", arguments: [massExpression])
        description.expression = avgExpression
        description.name = averageMassKey
        description.expressionResultType = .doubleAttributeType
        
        return description
    }()
    
    public static var totalEnergyDescription: NSExpressionDescription = {
        let description = NSExpressionDescription()
        let sumExpression = NSExpression(forFunction: "sum:", arguments: [energyExpression])
        description.expression = sumExpression
        description.name = totalEnergyKey
        description.expressionResultType = .doubleAttributeType
        
        return description
    }()
    
    public static var dateSortDescriptor = NSSortDescriptor(key: "created", ascending: false)
}
