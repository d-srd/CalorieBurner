//
//  UserDefaults.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 17/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation

public extension UserDefaults {
    static let massKey = "massUnit"
    static let energyKey = "energyUnit"
    static let dayOfWeekKey = "firstDayOfWeek"
    
    private static let massMap = [
        0 : UnitMass.kilograms,
        1 : UnitMass.pounds,
        2 : UnitMass.stones
    ]
    
    private static let energyMap = [
        0 : UnitEnergy.kilocalories,
        1 : UnitEnergy.kilojoules
    ]
    
    static func prepareMassForStorage(_ unit: UnitMass) -> Int {
        guard let index = massMap.first(where: { $1 == unit })?.key else {
            fatalError("no key for value")
        }
        
        return index
    }
    
    static func prepareEnergyForStorage(_ unit: UnitEnergy) -> Int {
        guard let index = energyMap.first(where: { $1 == unit })?.key else {
            fatalError("no key for value")
        }
        
        return index
    }
    
    /// User's prefered mass unit. Used in displaying diary entries.
    public var mass: UnitMass {
        get {
            let index = self.integer(forKey: UserDefaults.massKey)
            
            guard let unit = UserDefaults.massMap[index] else { fatalError("Index wrong") }
            return unit
        }
        set {
            let index = UserDefaults.prepareMassForStorage(newValue)
            self.set(index, forKey: UserDefaults.massKey)
            
            NotificationCenter.default.post(name: .UnitMassChanged, object: nil)
        }
    }
    
    /// User's preferred energy unit. Used in displaying diary entries.
    public var energy: UnitEnergy {
        get {
            let index = self.integer(forKey: UserDefaults.energyKey)
            guard let unit = UserDefaults.energyMap[index] else { fatalError("index wrong") }
            return unit
        }
        set {
            let index = UserDefaults.prepareEnergyForStorage(newValue)
            self.set(index, forKey: UserDefaults.energyKey)
            
            // maybe move this somewhere else?
            NotificationCenter.default.post(name: .UnitEnergyChanged, object: nil)
        }
    }
    
    /// User's preferred first day of week, represented numerically. It's the job of the caller to
    /// make sure that the value this property is set to is valid.
    /// e.g. in USA localization: Sunday - 1, Monday - 2, ... Saturday - 7
    public var firstDayOfWeek: Int {
        get {
            return self.integer(forKey: UserDefaults.dayOfWeekKey)
        } set {
            self.set(newValue, forKey: UserDefaults.dayOfWeekKey)
            NotificationCenter.default.post(name: .FirstDayOfWeekDidChange, object: nil)
            print("set first day of week to: ", newValue)
        }
    }
}
