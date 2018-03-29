//
//  UserDefaults.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 17/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation

extension UserDefaults {
    /// User's prefered mass unit.
    var mass: UnitMass? {
        get {
            guard let encodedUnit = self.object(forKey: "massUnit") as? Data else { return nil }
            return NSKeyedUnarchiver.unarchiveObject(with: encodedUnit) as? UnitMass
        }
        set {
            guard let massUnit = newValue else { return }
            let encodedUnit = NSKeyedArchiver.archivedData(withRootObject: massUnit)
            self.set(encodedUnit, forKey: "massUnit")
            NotificationCenter.default.post(name: .UnitMassChanged, object: nil)
        }
    }
    
    /// User's preferred energy unit.
    var energy: UnitEnergy? {
        get {
            guard let encodedUnit = self.object(forKey: "energyUnit") as? Data else { return nil }
            return NSKeyedUnarchiver.unarchiveObject(with: encodedUnit) as? UnitEnergy
        }
        set {
            guard let energyUnit = newValue else { return }
            let encodedUnit = NSKeyedArchiver.archivedData(withRootObject: energyUnit)
            self.set(encodedUnit, forKey: "energyUnit")
            NotificationCenter.default.post(name: .UnitEnergyChanged, object: nil)
        }
    }
    
    /// User's preferred first day of week, represented numerically.
    /// e.g. in USA localization: Sunday - 1, Monday - 2, ... Saturday - 7
    var firstDayOfWeek: Int {
        get {
            return self.integer(forKey: "firstDayOfWeek")
        } set {
            self.set(newValue, forKey: "firstDayOfWeek")
            NotificationCenter.default.post(name: .FirstDayOfWeekDidChange, object: nil)
            print("set first day of week to: ", newValue)
        }
    }
}
