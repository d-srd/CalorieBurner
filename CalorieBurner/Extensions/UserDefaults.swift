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
            return self.object(forKey: "massUnit") as? UnitMass
//            let archive = NSKeyedUnarchiver(forReadingWith: encodedMassUnit)
//            return UnitMass(coder: archive)
        }
        set {
            guard let massUnit = newValue else { return }
//            let encodedMassUnit = NSKeyedArchiver.archivedData(withRootObject: massUnit)
            self.set(massUnit, forKey: "massUnit")
        }
    }
    
    var energy: UnitEnergy? {
        get {
            return self.object(forKey: "energyUnit") as? UnitEnergy
//            guard let encodedEnergyUnit = self.data(forKey: "energyUnit") else { return nil }
//            let archive = NSKeyedUnarchiver(forReadingWith: encodedEnergyUnit)
//            return UnitEnergy(coder: archive)
        }
        set {
            guard let energyUnit = newValue else { return }
//            let encodedEnergyUnit = NSKeyedArchiver.archivedData(withRootObject: energyUnit)
            self.set(energyUnit, forKey: "energyUnit")
        }
    }
}
