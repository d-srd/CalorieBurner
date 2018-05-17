//
//  HealthStoreHelper.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 30/04/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import HealthKit
import CoreData

protocol DailyModelConvertible {
    associatedtype Data
    
    func convert(data: Data, context: NSManagedObjectContext) -> Daily
    func convertAll(in context: NSManagedObjectContext) -> [Daily]
}

class HealthStoreHelper {
    // this should only ever be a single instance across the entire app, according to Apple
    private let store: HKHealthStore

    private let typesToRead: Set<HKSampleType>
    private let typesToWrite: Set<HKSampleType>

    // saves some typing
    private let massSample = HKObjectType.quantityType(forIdentifier: .bodyMass)!
    private let energySample = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
    
    // this is necessary for stopping the appropriate queries if it didn't fetch any results
    private var didExecuteAnchoredQuery = false
    private var didExecuteStatisticsQuery = false
    
    // anchor query uses this so it doesn't have to fetch everything all over again
    private var anchor: HKQueryAnchor?
    
    // the queries' completion handlers assign their values to these variables when they fetch the appropriate data
    private var energyResults = [Date : HKQuantity]()
    private var massResults = [Date : HKQuantitySample]()
    
    private lazy var statisticsQuery = makeEnergyStatisticsQuery()
    private lazy var anchoredQuery = makeAnchoredMassQuery()
    
    private static let defaultTypes = Set([HKObjectType.quantityType(forIdentifier: .bodyMass)!, HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!])
    
    // we need a singleton health store, as they are long lived objects
    static let storeSingleton = HKHealthStore()
    
    static let shared = HealthStoreHelper(store: storeSingleton, readingTypes: defaultTypes, writingTypes: defaultTypes)
    
    init(store: HKHealthStore, readingTypes: Set<HKSampleType> = defaultTypes, writingTypes: Set<HKSampleType> = defaultTypes) {
        self.store = store
        typesToRead = readingTypes
        typesToWrite = writingTypes
    }
    
    func requestAuthorization(_ completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HKError(.errorHealthDataUnavailable))
            return
        }
        
        store.requestAuthorization(toShare: typesToWrite, read: typesToRead) { (success, error) in
            completion(success, error)
        }
    }
    
    func writeData(sample: HKQuantitySample, _ completion: @escaping (Bool, Error?) -> Void) {
        store.save(sample, withCompletion: completion)
    }
    
    // set up observer queries for both mass and energy
    func enableBackgroundDelivery() {
        let massQuery = HKObserverQuery(sampleType: massSample,
                                        predicate: nil)
        { [unowned self] (query, completion, error) in
            guard error == nil else { fatalError("mass observer completion handler failed. \(error?.localizedDescription)") }
            
            if !self.didExecuteAnchoredQuery {
                // remove deleted objects, then merge the results back into the massResults
                self.anchoredQuery = self.makeAnchoredMassQuery(completion: completion) { results, deletions in
                    self.massResults = self.massResults.filter { item in
                        return !deletions.contains(where: { $0.uuid == item.value.uuid })
                    }
                    self.massResults.merge(results) { (first, second) in return first }
                }
                self.store.execute(self.anchoredQuery)
                self.didExecuteAnchoredQuery = true
            } else {
                self.store.stop(self.anchoredQuery)
                self.anchoredQuery = self.makeAnchoredMassQuery(completion: completion) { results, deletions in
                    self.massResults = results
                }
                self.store.execute(self.anchoredQuery)
            }
        }
        
        let energyQuery = HKObserverQuery(sampleType: energySample,
                                          predicate: nil)
        { [unowned self] (query, completion, error) in
            guard error == nil else { fatalError("energy observer completion handler failed. \(error?.localizedDescription)") }
            
            if !self.didExecuteStatisticsQuery {
                self.store.execute(self.statisticsQuery)
                self.didExecuteStatisticsQuery = true
            } else {
                self.store.stop(self.statisticsQuery)
                self.statisticsQuery = self.makeEnergyStatisticsQuery(completion: completion) { results in
                    self.energyResults = results
                }
                self.store.execute(self.statisticsQuery)
            }
        }
        
        store.execute(massQuery)
        store.execute(energyQuery)
        
        func completion(success: Bool, error: Error?) {
            guard success else {
                print("** error occured during background delivery setup completion handler **")
                print(error?.localizedDescription)
                abort()
            }
        }
        
        store.enableBackgroundDelivery(for: massSample,
                                       frequency: .immediate,
                                       withCompletion: completion)
        
        store.enableBackgroundDelivery(for: energySample,
                                       frequency: .immediate,
                                       withCompletion: completion)
    }
    
    private func makeEnergyStatisticsQuery(completion: (() -> Void)? = nil,
                                           didProcessValues valueProcessing: (([Date : HKQuantity]) -> Void)? = nil)
        -> HKStatisticsCollectionQuery
    {
        let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: Date(timeIntervalSinceReferenceDate: 0),
                                                intervalComponents: DateComponents(day: 1))
        
        query.initialResultsHandler = { (query, results, error) in
            guard let results = results,                // no results. fail silently
                  !results.statistics().isEmpty         // results are empty
            else { return }
            
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -3, to: endDate)!
            
            var caloriesPerDate = [Date : HKQuantity]()
            
            results.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate.startOfDay
                    caloriesPerDate[date] = quantity
                }
            }
            
            valueProcessing?(caloriesPerDate)
            completion?()
        }
        
        return query
    }
    
    private func makeAnchoredMassQuery(completion: (() -> Void)? = nil,
                                       didProcessValues valueProcessing: (([Date : HKQuantitySample], [HKDeletedObject]) -> Void)? = nil)
        -> HKAnchoredObjectQuery
    {
        func anchorUpdateHandler(query: HKAnchoredObjectQuery, samples: [HKSample]?, deletions: [HKDeletedObject]?, newAnchor: HKQueryAnchor?, error: Error?) {
            guard let samples = samples, let deletions = deletions else { print("error initial"); return }
            
            anchor = newAnchor

            var values = [Date : HKQuantitySample]()
            for sample in samples {
                values[sample.startDate.startOfDay] = sample as? HKQuantitySample
            }
            
            valueProcessing?(values, deletions)
            
            completion?()
        }
        
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                                          predicate: nil,
                                          anchor: anchor,
                                          limit: HKObjectQueryNoLimit,
                                          resultsHandler: anchorUpdateHandler)
        query.updateHandler = anchorUpdateHandler
        
        return query
    }
}

extension HealthStoreHelper: DailyModelConvertible {
    typealias Data = (date: Date, mass: Double?, energy: Double?)
    
    func convert(data: Data, context: NSManagedObjectContext) -> Daily {
        let (date, mass, energy) = data
        let daily = Daily(context: context, date: date)
        daily.updateValues(mass: mass, energy: energy)
        
        return daily
    }
    
    func convertAll(in context: NSManagedObjectContext) -> [Daily] {
        let dates = Set(energyResults.keys).union(Set(massResults.keys))
        return dates
            .sorted()
            .map { date in
                let massValue = massResults[date]?.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                let energyValue = energyResults[date]?.doubleValue(for: HKUnit.kilocalorie())
                return convert(data: (date, massValue, energyValue), context: context)
            }
    }

}
