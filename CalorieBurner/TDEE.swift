//
//  TDEECalculator.swift
//  WeeklyBurner
//
//  Created by Dino Srdoč on 10/12/2017.
//  Copyright © 2017 Dino Srdoč. All rights reserved.
//

import Foundation
import CoreData

// TODO: - clean this shit up
extension Date {
    var startOfWeek: Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}

extension Array {
    func fill(withSize size: Int) -> [Element]? {
        guard !isEmpty else { return nil }
        
        return (0..<size).map { idx in
            return self[safe: idx] ?? self[self.indices.last!]
        }
    }
    
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        
        return self[index]
    }
}

// TODO: use an actual data structure
typealias Weeks = [Date : (averageMass: Double, totalEnergy: Double)]
typealias DateRange = (start: Date, end: Date)

// TODO: document and explain this

protocol CalorieTransformer: AnyObject {
    func transformDailies() -> Weeks
}

public class TDEEMediator: CalorieTransformer {
    
    private let context: NSManagedObjectContext
    var startDate: Date
    var endDate: Date
    
    private var dateRange: (start: Date, end: Date) {
        return (startDate, endDate)
    }
    
    init(context: NSManagedObjectContext, startDate: Date, endDate: Date) {
        self.context = context
        self.startDate = startDate
        self.endDate = endDate
    }
    
    private func fetchDailies() throws -> [Daily] {
        let request = Daily.fetchRequest(in: dateRange)
        return try context.fetch(request)
    }
    
    func averageMass() -> Double? {
        guard let entries = try? fetchDailies() else { return nil }
        
        return entries.reduce(0) { $0 + ($1.mass?.value ?? 0) } / Double(entries.count)
    }
    
    func sumEnergy() -> Double? {
        guard let entries = try? fetchDailies() else { return nil }
        
        return entries.reduce(0) { $0 + ($1.energy?.value ?? 0) }
    }
    
    private func groupByWeek(dailies: [Daily]) -> [Date : [Daily]] {
        let groupPredicate = { (element: Daily) in
            return element.created!.startOfWeek!
        }
        
        let sorted = dailies.sorted { $0.created! < $1.created! }
        let grouped = Dictionary(grouping: sorted, by: groupPredicate)
        
        return grouped
            .mapValues { $0.fill(withSize: 7)! }
    }
    
    func transformDailies() -> Weeks {
        guard let entries = try? fetchDailies() else { fatalError("oops") }
        let grouped = groupByWeek(dailies: entries)
        
        return grouped.mapValues { week in
            let averageMass = week.reduce(0) { $0 + ($1.mass?.value ?? 0) } / Double(week.count)
            let sumOfEnergy = week.reduce(0) { $0 + ($1.energy?.value ?? 0) }
            return (averageMass, sumOfEnergy)
        }
    }
}

public struct CalorieBrain {
    private struct Constants {
        static let kCalPerGramOfFat = (min: 8.7, max: 9.5)
        static let lipidPercentPerKilogramOfTissue = (min: 0.72, max: 0.87)
        static let kCalPerKilogramOfTissue = {
            return (
                min: kCalPerGramOfFat.min * 1000 * lipidPercentPerKilogramOfTissue.min,
                max: kCalPerGramOfFat.max * 1000 * lipidPercentPerKilogramOfTissue.max
            )
        }()
        static let kCalPerKG = {
            return (kCalPerKilogramOfTissue.min + kCalPerKilogramOfTissue.max) / 2
        }()
    }

//    private func deltas(from dailies: [Daily]) -> (mass: Double?, energy: Double?)? {
//        guard !dailies.isEmpty else { return nil }
//
//        let weeks = makeWeeks(from: dailies)
//            .sorted { $0.key < $1.key }
//            .map { $1 }
//
//        let averageWeeklyEnergy = weeks.map { week in
//            return week.reduce(0) { $0 + ($1.energy?.value ?? 0) } / Double(week.count)
//        }
//
//        let averageWeeklyMass = weeks.map { week in
//            return week.reduce(0) { $0 + ($1.mass?.value ?? 0) } / Double(week.count)
//        }
//
//        let mass = averageWeeklyMass[averageWeeklyMass.count - 2] - averageWeeklyMass[averageWeeklyMass.count - 1]
//        let energy = averageWeeklyEnergy[averageWeeklyEnergy.count - 2] - averageWeeklyEnergy[averageWeeklyEnergy.count - 1]
//
//        return (mass, energy)
//    }
    

    func calculateTDEE(from weeks: Weeks) -> Double? {
        guard !weeks.isEmpty else {
            return nil
        }

        guard weeks.count > 1 else {
            return weeks.values.first!.totalEnergy / 7
        }

        let thing = weeks
            .sorted { $0.key.compare($1.key) == .orderedDescending }
            .map { $0.value }
        let mass = thing.map { $0.averageMass }
        let energy = thing.map { $0.totalEnergy }

        let deltaMass = mass.last! - mass.first!

        return (energy.reduce(0, +) - deltaMass * Constants.kCalPerKG) / (Double(weeks.count) * 7.0)
    }
}

