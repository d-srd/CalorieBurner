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
    
    /// User's prefered mass unit. Used in displaying diary entries.
    public var mass: UnitMass {
        get {
            let encodedUnit = self.object(forKey: UserDefaults.massKey) as! Data
            let className = String(describing: type(of: UnitMass.self))
            NSKeyedUnarchiver.setClass(UnitMass.self, forClassName: className)
            return NSKeyedUnarchiver.unarchiveObject(with: encodedUnit) as! UnitMass
        }
        set {
            let className = String(describing: type(of: UnitMass.self))
            NSKeyedArchiver.setClassName(className, for: UnitMass.self)
            let encodedUnit = NSKeyedArchiver.archivedData(withRootObject: newValue)
            self.set(encodedUnit, forKey: UserDefaults.massKey)
            NotificationCenter.default.post(name: .UnitMassChanged, object: nil)
        }
    }
    
    /// User's preferred energy unit. Used in displaying diary entries.
    public var energy: UnitEnergy {
        get {
            let encodedUnit = self.object(forKey: UserDefaults.energyKey) as! Data
            let className = String(describing: type(of: UnitEnergy.self))
            NSKeyedUnarchiver.setClass(UnitEnergy.self, forClassName: className)
            return NSKeyedUnarchiver.unarchiveObject(with: encodedUnit) as! UnitEnergy
        }
        set {
            let className = String(describing: type(of: UnitEnergy.self))
            NSKeyedArchiver.setClassName(className, for: UnitEnergy.self)
            let encodedUnit = NSKeyedArchiver.archivedData(withRootObject: newValue)
            self.set(encodedUnit, forKey: UserDefaults.energyKey)
            
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
