//
//  Unit.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 02/04/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation

// this is needed for unit (de)serialization to UserDefaults, otherwise different
// instances of Unit<Mass/Energy>'s class vars would point to differnet objects in memory
// which would cause them to have different hash values and thus render them incompatible
// for use in sets and dictionaries
extension UnitMass {
    open override var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

extension UnitEnergy {
    open override var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}
