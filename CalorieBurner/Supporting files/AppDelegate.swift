//
//  AppDelegate.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 25/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import HealthKit

// we need a singleton health store, as they are long lived objects
public let healthStore = HKHealthStore()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // put some default values in UserDefaults
        let defaultUserDefaults: [String : Any] = [
            UserDefaults.massKey : UserDefaults.prepareMassForStorage(UnitMass.kilograms),
            UserDefaults.energyKey : UserDefaults.prepareEnergyForStorage(UnitEnergy.kilocalories),
            UserDefaults.dayOfWeekKey : 1
        ]
        UserDefaults.standard.register(defaults: defaultUserDefaults)
        
        // make the keyboard scared of any text fields
        IQKeyboardManager.shared.enable = true
        
        
        HealthStoreHelper.shared.requestAuthorization { (success, error) in
            guard error == nil else {
                print("oops")
                return
            }
        }
        
        // register long running health observer queries
        let massSample = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let energySample = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        
        let massQuery = HKObserverQuery(sampleType: massSample, predicate: nil) { [weak self] (query, completion, err) in
            guard err == nil else {
                print("** An error occurred whilst setting up mass observer query. \(err) Aborting. **")
                abort()
            }
            
            self?.handleHealthUpdate(fromQuery: query)
            completion()
        }
        let energyQuery = HKObserverQuery(sampleType: energySample, predicate: nil) { [weak self] (query, completion, err) in
            guard err == nil else {
                print("** An error occurred whilst setting up mass observer query. \(err) Aborting. **")
                abort()
            }
            
            self?.handleHealthUpdate(fromQuery: query)
            completion()
        }
        
        healthStore.execute(massQuery)
        healthStore.execute(energyQuery)
        
        healthStore.enableBackgroundDelivery(for: massSample, frequency: .immediate) { (success, error) in
            guard error == nil else {
                print("* error occured setting up background delivery. \(error).*")
                abort()
            }
        }
        healthStore.enableBackgroundDelivery(for: energySample, frequency: .immediate) { (success, error) in
            guard error == nil else {
                print("* error occured setting up background delivery. \(error).*")
                abort()
            }
        }
        
        return true
    }
    
    private var anchor: HKQueryAnchor?
    
    private lazy var anchoredQuery: HKAnchoredObjectQuery = {
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
        }
        
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                                          predicate: nil,
                                          anchor: anchor,
                                          limit: HKObjectQueryNoLimit,
                                          resultsHandler: anchorUpdateHandler)
        query.updateHandler = anchorUpdateHandler
        
        return query
    }()
    
    private lazy var statisticsQuery: HKStatisticsCollectionQuery = {
        let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: Date(timeIntervalSinceReferenceDate: 0),
                                                intervalComponents: DateComponents(day: 1))
        
        query.initialResultsHandler = { (query, results, error) in
            guard let results = results else { print("error retrieving values"); return }
            
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -3, to: endDate)!
            
            results.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.kilocalorie())
                    
                    print("found initial calories: \(value) for date: \(date)")
                }
            }
        }
        
        query.statisticsUpdateHandler = { (query, data, results, error) in
            print("updated stats")
            guard let updatedItem = data?.sumQuantity() else { print("error retrieving values"); return }
            
            
            print("found updated calories: \(updatedItem)")
        }
    
        return query
    }()
    
    private var didExecuteStatisticsQuery = false
    private var didExecuteAnchoredQuery = false

    private func handleHealthUpdate(fromQuery query: HKObserverQuery) {
        guard let objectType = query.objectType else { return }
        
        if objectType == HKObjectType.quantityType(forIdentifier: .bodyMass)! && !didExecuteAnchoredQuery {
            healthStore.execute(anchoredQuery)
            didExecuteAnchoredQuery = true
        } else if objectType == HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed) && !didExecuteStatisticsQuery {
            healthStore.execute(statisticsQuery)
            didExecuteStatisticsQuery = true
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

