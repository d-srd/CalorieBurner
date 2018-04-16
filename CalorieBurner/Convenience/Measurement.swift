//
//  Measurement.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 04/04/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation

/// Convenience type for Measurement\<UnitMass\>
typealias Mass = Measurement<UnitMass>

/// Convenience type for Measurement\<UnitEnergy\>
typealias Energy = Measurement<UnitEnergy>

/// 
@objc enum MeasurementItems: Int {
    case mass
    case energy
}
