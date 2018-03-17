//
//  UserDefaults.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 17/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation

extension UserDefaults {
    var mass: UnitMass? {
        get {
            guard let encodedMassUnit = self.data(forKey: "massUnit") else { return nil }
            return NSKeyedUnarchiver.unarchiveObject(with: encodedMassUnit) as? UnitMass
        }
        set {
            guard let massUnit = newValue else { return }
            let encodedMassUnit = NSKeyedArchiver.archivedData(withRootObject: massUnit)
            self.set(encodedMassUnit, forKey: "massUnit")
        }
    }
    
    var energy: UnitEnergy? {
        get {
            guard let encodedEnergyUnit = self.data(forKey: "energyUnit") else {
                return nil
            }
            return NSKeyedUnarchiver.unarchiveObject(with: encodedEnergyUnit) as? UnitEnergy
        }
        set {
            guard let energyUnit = newValue else { return }
            let encodedEnergyUnit = NSKeyedArchiver.archivedData(withRootObject: energyUnit)
            self.set(encodedEnergyUnit, forKey: "energyUnit")
        }
    }
}
