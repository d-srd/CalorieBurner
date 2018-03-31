//
//  TDEECalculator.swift
//  WeeklyBurner
//
//  Created by Dino Srdoč on 10/12/2017.
//  Copyright © 2017 Dino Srdoč. All rights reserved.
//

import Foundation
import CoreData

public class TDEEMediator {
    var startDate: Date
    var endDate: Date
//    let request: NSFetchRequest
    let context: NSManagedObjectContext
    
//    lazy var request = Daily.fetchRequest(in: (startDate, endDate))
    
    init(startDate: Date, endDate: Date, context: NSManagedObjectContext) {
        self.startDate = startDate
        self.endDate = endDate
        self.context = context
//        request = Daily.fetchRequest(in: (startDate, endDate))
    }
    
    func avgMass() -> Double {
        let request = Daily.dictionaryFetchRequest(in: (startDate, endDate), properties: [Daily.massExpressionKey])
        request.propertiesToFetch = [Daily.averageMassDescription]
        request.resultType = .dictionaryResultType
        
        let things = try! context.fetch(request)
        let dict = things[0] as! [String : Double]
        let value = dict[Daily.averageMassKey]!
        
        print(value)
        
        return value
    }
    
    func sumEnergy() -> Double {
        
        let request = Daily.dictionaryFetchRequest(in: (startDate, endDate), properties: [Daily.energyExpressionKey])
        //            request.returnsObjectsAsFaults = false
        request.propertiesToFetch = [Daily.totalEnergyDescription]
        //            request.propertiesToGroupBy = ["energy"]
        request.resultType = .dictionaryResultType
        //            request.returnsDistinctResults = true
        
        let things = try! context.fetch(request)
        let dict = things[0] as! [String : Double]
        let value = dict[Daily.totalEnergyKey]!
        
        print(value)
        
        return value
        
    }
}

//struct TDEE {
//    private struct Constants {
//        static let kCalPerGramOfFat = (min: 8.7, max: 9.5)
//        static let lipidPercentPerKilogramOfTissue = (min: 0.72, max: 0.87)
//        static let kCalPerKilogramOfTissue = {
//            return (
//                min: kCalPerGramOfFat.min * 1000 * lipidPercentPerKilogramOfTissue.min,
//                max: kCalPerGramOfFat.max * 1000 * lipidPercentPerKilogramOfTissue.max
//            )
//        }()
//        static let kCalPerKG = {
//            return (kCalPerKilogramOfTissue.min + kCalPerKilogramOfTissue.max) / 2
//        }()
//    }
//
//    private let totalWeeklyEnergy: [Double]
//    private let averageWeeklyEnergy: [Double]
//    private let averageWeeklyMass: [Double]
//
//    private func makeWeeks(fromEntries entries: [Entry]) -> [Date : [Entry]] {
//        return entries
//            .sorted { $0.date < $1.date }
//            .groupByKey { $0.date.startOfWeek! }
//            .mapValues { $0.fill(withSize: 7)! }
//    }
//
//    // TODO: use fast database functions instead of slow client side code
//    // i mean everything here is the client, but still
//    func calculate(with entries: [Entry]) -> Double? {
//        guard !entries.isEmpty else { return nil }
//
//        let weeks = makeWeeks(fromEntries: entries)
//            .sorted { $0.key < $1.key }
//            .map { $1 }
//
//        let totalWeeklyEnergy = weeks.map { week in
//            return week.map { $0.energy }.sum()
//        }
//        let averageWeeklyMass = weeks.map { week in
//            return week.map { $0.mass }.average()
//        }
//
//        for idx in (0..<totalWeeklyEnergy.count) {
//            print("Energy: ", totalWeeklyEnergy[idx], "Mass: ", averageWeeklyMass[idx])
//        }
//
//        guard weeks.count > 1 else {
//            return totalWeeklyEnergy.first! / 7
//        }
//
//        let deltaMass = averageWeeklyMass.last! - averageWeeklyMass.first!
//        print("Delta mass: ", deltaMass)
//        let kCalPerKilogram = (Constants.kCalPerKilogramOfTissue.min + Constants.kCalPerKilogramOfTissue.max) / 2
//        print("Cal per kg: ", kCalPerKilogram)
//        print("Cals from delta mass: ", kCalPerKilogram * deltaMass)
//
//        return (abs(totalWeeklyEnergy.reduce(0, +) - deltaMass * kCalPerKilogram)) / Double(totalWeeklyEnergy.count * 7)
//    }
//
//    func deltas(from entries: [Entry]) -> (mass: Double?, energy: Double?)? {
//        guard !entries.isEmpty else { return nil }
//
//        let weeks = makeWeeks(fromEntries: entries)
//            .sorted { $0.key < $1.key }
//            .map { $1 }
//
//        let averageWeeklyEnergy = weeks.map { week in
//            return week.map { $0.energy }.average()
//        }
//
//        let averageWeeklyMass = weeks.map { week in
//            return week.map { $0.mass }.average()
//        }
//
//        let mass = averageWeeklyMass[averageWeeklyMass.count - 2] - averageWeeklyMass[averageWeeklyMass.count - 1]
//        let energy = averageWeeklyEnergy[averageWeeklyEnergy.count - 2] - averageWeeklyEnergy[averageWeeklyEnergy.count - 1]
//
//        return (mass, energy)
//    }
//
//    func calculate(from weeks: [Date : (averageMass: Double, totalEnergy: Double)]) -> Double? {
//        guard !weeks.isEmpty else {
//            return nil
//        }
//
//        guard weeks.count > 1 else {
//            return weeks.values.first!.totalEnergy / 7
//        }
//
//        let thing = weeks
//            .sorted { $0.key.compare($1.key) == .orderedDescending }
//            .map { $0.value }
//        let mass = thing.map { $0.averageMass }
//        let energy = thing.map { $0.totalEnergy }
//
//        let deltaMass = mass.last! - mass.first!
//
//        return (abs(energy.reduce(0, +) - deltaMass) * Constants.kCalPerKG) / (Double(weeks.count) * 7.0)
//    }
//}

