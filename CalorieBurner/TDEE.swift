//
//  TDEECalculator.swift
//  WeeklyBurner
//
//  Created by Dino Srdoč on 10/12/2017.
//  Copyright © 2017 Dino Srdoč. All rights reserved.
//

import Foundation
import CoreData

/// Representation of a single week containing mass and energy measurements.
/// Used internally for TDEE calculations.
public struct Week: Hashable {
    let start: Date
    let masses: [Double]
    let energies: [Double]
    
    var averageMass: Double {
        return masses.reduce(0, +) / Double(masses.count)
    }
    
    var averageEnergy: Double {
        return energies.reduce(0, +) / Double(energies.count)
    }
    
    var totalEnergy: Double {
        return energies.reduce(0, +)
    }
    
    public var hashValue: Int {
        return start.hashValue
    }
}

typealias DateRange = (start: Date, end: Date)

/// Transform CoreData model to internal model
protocol CalorieTransformer: AnyObject {
    func transformDailies() -> [Week]
}

/// Convert CoreData `Daily` entries to `Week`
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
    
    private func groupByWeek(dailies: [Daily]) -> [Date : [Daily]] {
        let groupPredicate = { (element: Daily) in
            return element.created!.startOfWeek!
        }
        
        let sorted = dailies.sorted { $0.created! < $1.created! }
        let grouped = Dictionary(grouping: sorted, by: groupPredicate)
        
        return grouped
            .mapValues { $0.fill(withSize: 7)! }
    }
    
    func transformDailies() -> [Week] {
        guard let entries = try? fetchDailies() else { fatalError("oops") }
        let grouped = groupByWeek(dailies: entries)
        
        // units may not be canonical (kilograms, kilocalories), so we convert them here
        return grouped.map { date, dailies in
            let masses = dailies.compactMap { $0.mass?.converted(to: .kilograms).value }
            let energies = dailies.compactMap { $0.energy?.converted(to: .kilocalories).value }
            return Week(start: date, masses: masses, energies: energies)
        }
    }
}

public struct CalorieBrain {
    // Kilocalories per gram of fat vary wildly from person to person.
    // Not to mention that it's very hard to accurately track fat burned
    // by a single person even with the newest, most specialized tools.
    // This is a simple way to get an approximation suitable for calculating a range.
    // In the future, this could be used to correct TDEE calculation offsets
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
    
    func calculateDelta(_ item: MeasurementItems, from weeks: [Week]) -> Double? {
        guard !weeks.isEmpty else { return nil }
        
        guard weeks.count > 1 else {
            switch item {
            case .mass: return weeks.first!.averageMass
            case .energy: return weeks.first!.averageEnergy
            }
        }
        
        switch item {
        case .mass:
            return weeks[weeks.count - 1].averageMass - weeks[weeks.count - 2].averageMass
        case .energy:
            return weeks[weeks.count - 1].averageEnergy - weeks[weeks.count - 2].averageEnergy
        }
        
    }
    
    /// Initial TDEE approximation for a given person. Weekly calculations are more accurate.
    func calculateTDEE(for user: UserRepresentable) -> Double? {
        return calculateBMR(for: user).map { $0 * user.activityLevel.multiplier }
    }
    
    /// BMR - Basal Metabolic Rate.
    /// Uses the revised Harris-Benedict equation:
    /// https://en.wikipedia.org/wiki/Harris–Benedict_equation#cite_note-3
    func calculateBMR(for user: UserRepresentable) -> Double? {
        guard 0 < user.age, user.age < 150,
            55 < user.height, user.height < 275,
            30 < user.weight, user.weight < 350
            else { return nil }
        
        let constant, weight, height, age: Double
        
        if user.sex == .male {
            constant = 88.362
            weight = 13.397 * user.weight
            height = 4.799 * user.height
            age = 5.677 * Double(user.age)
        } else {
            constant = 447.593
            weight = 9.247 * user.weight
            height = 3.098 * user.height
            age = 4.330 * Double(user.age)
        }
        
        return constant + weight + height - age
    }

    func calculateTDEE(using weeks: [Week]) -> Double? {
        guard !weeks.isEmpty else { return nil }

        guard weeks.count > 1 else {
            return weeks.first!.averageEnergy
        }

        let sorted = weeks.sorted { $0.start < $1.start }
        let weeklyTDEEs = sorted.map { (week) -> Double in
            let weeklyDeltaMass = week.masses.last! - week.masses.first!
            return week.averageEnergy + ((-weeklyDeltaMass * Constants.kCalPerKG) / 7.0)
        }

        return weeklyTDEEs.reduce(0, +) / Double(weeklyTDEEs.count)
    }
}

