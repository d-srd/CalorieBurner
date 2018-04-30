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
        
        store.requestAuthorization(toShare: typesToWrite, read: typesToRead) { (success, error) in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    func writeData(mass: HKQuantitySample, _ completion: @escaping (Bool, Error?) -> Void) {
        store.save(mass, withCompletion: completion)
    }
}
