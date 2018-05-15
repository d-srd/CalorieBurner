//
//  HealthStoreHelper.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 30/04/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import HealthKit

class HealthStoreHelper {
    private let store: HKHealthStore
    private let typesToRead: Set<HKSampleType>
    private let typesToWrite: Set<HKSampleType>
    
    private let massSample = HKObjectType.quantityType(forIdentifier: .bodyMass)!
    private let energySample = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
    
    private var didExecuteAnchoredQuery = false
    private var didExecuteStatisticsQuery = false
    
    private var isAuthorized = false
    private var anchor: HKQueryAnchor?
    
    private lazy var statisticsQuery = makeEnergyStatisticsQuery()
    private lazy var anchoredQuery = makeAnchoredMassQuery()
    
    private static let defaultTypes = Set([HKObjectType.quantityType(forIdentifier: .bodyMass)!, HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!])
    
    static let shared = HealthStoreHelper(store: healthStore, readingTypes: defaultTypes, writingTypes: defaultTypes)
    
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
        
        store.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] (success, error) in
            completion(success, error)
            self?.isAuthorized = true
        }
    }
    
    func writeData(sample: HKQuantitySample, _ completion: @escaping (Bool, Error?) -> Void) {
        store.save(sample, withCompletion: completion)
    }
    
    // set up observer queries for both mass and energy
    func enableBackgroundDelivery() {
        let massQuery = HKObserverQuery(sampleType: massSample,
                                        predicate: nil)
        { [weak self] (query, completion, error) in
            guard error == nil, let wself = self else {
                print("** error occured during observer query completion handler **")
                print(error!.localizedDescription)
                abort()
            }
            
            if !wself.didExecuteAnchoredQuery {
                wself.anchoredQuery = wself.makeAnchoredMassQuery(completion)
                wself.store.execute(wself.anchoredQuery)
                wself.didExecuteAnchoredQuery = true
            }
        }
        
        let energyQuery = HKObserverQuery(sampleType: energySample,
                                          predicate: nil)
        { [weak self] (query, completion, error) in
            guard error == nil, let wself = self else {
                print("** error occured during observer query completion handler **")
                print(error!.localizedDescription)
                abort()
            }
            
            if !wself.didExecuteStatisticsQuery {
                wself.store.execute(wself.statisticsQuery)
                wself.didExecuteStatisticsQuery = true
            } else {
                wself.store.stop(wself.statisticsQuery)
                wself.statisticsQuery = wself.makeEnergyStatisticsQuery(completion)
                wself.store.execute(wself.statisticsQuery)
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
    
    private func makeEnergyStatisticsQuery(_ completion: (() -> Void)? = nil) -> HKStatisticsCollectionQuery {
        let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: Date(timeIntervalSinceReferenceDate: 0),
                                                intervalComponents: DateComponents(day: 1))
        
        query.initialResultsHandler = { [weak self] (query, results, error) in
            guard let results = results else {
                print("error retrieving values")
                return
            }
            
            guard !results.statistics().isEmpty else {
                print("no initial values for statistics. resetting")
                return
            }
            
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -3, to: endDate)!
            
            results.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.kilocalorie())
                    
                    print("found initial calories: \(value) for date: \(date)")
                }
            }
            
            completion?()
        }
        
        query.statisticsUpdateHandler = { [weak self] (query, results, collection, error) in
            //            guard let results = results else {
            //                print("error updating values")
            //                return
            //            }
            
            if let value = results?.sumQuantity(), let date = results?.startDate {
                print("found updated calories: \(value) for date: \(date)")
            } else {
                print("no values apparently")
                print("info dump: ", query, results, collection, error)
            }
        }
        
        return query
    }
    
    private func makeAnchoredMassQuery(_ completion: (() -> Void)? = nil) -> HKAnchoredObjectQuery {
        func anchorUpdateHandler(query: HKAnchoredObjectQuery, samples: [HKSample]?, deletions: [HKDeletedObject]?, newAnchor: HKQueryAnchor?, error: Error?) {
            guard let samples = samples, let deletions = deletions else { print("error initial"); return }
            
            anchor = newAnchor
            
            print("Printing samples")
            for sample in samples {
                print(sample)
            }
            
            print("Printing deletions")
            for deletion in deletions {
                print(deletion)
            }
            
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
