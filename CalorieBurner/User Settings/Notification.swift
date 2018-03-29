//
//  Notification.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 17/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let UnitMassChanged = Notification.Name("unitMassChanged")
    static let UnitEnergyChanged = Notification.Name("unitEnergyChanged")
    static let FirstDayOfWeekDidChange = Notification.Name("firstDayOfWeekDidChange")
}
