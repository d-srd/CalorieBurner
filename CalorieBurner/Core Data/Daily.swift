//
//  Daily.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 25/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import CoreData

/// Representation of a single day containing a mass and an energy
class Daily: NSManagedObject {
    
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
    
    /// Fetch request for doing arithmetic with the object's properties
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
    
    // used solely to filter arithmetic functions in fetch requests
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
