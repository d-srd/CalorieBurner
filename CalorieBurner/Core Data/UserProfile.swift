//
//  UserProfile+CoreDataProperties.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 21/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//
//

import Foundation
import CoreData

@objc public enum ActivityLevel: Int16 {
    case sedentary, light, moderate, heavy, extreme
    
    var multiplier: Float {
        switch self {
        case .sedentary:
            return 1.2
        case .light:
            return 1.375
        case .moderate:
            return 1.55
        case .heavy:
            return 1.725
        case .extreme:
            return 1.9
        }
    }
}

@objc public enum Sex: Int16 {
    case male, female
}

protocol UserRepresentable {
    var activityLevel: ActivityLevel { get set }
    var age: Int16 { get set }
    var height: Double { get set }
    var weight: Double { get set }
    var sex: Sex { get set }
}

public final class UserProfile: NSManagedObject, UserRepresentable {
    public var activityLevel: ActivityLevel {
        get { return ActivityLevel(rawValue: activityLevelID)! }
        set { activityLevelID = newValue.rawValue }
    }
    
    public var sex: Sex {
        get { return Sex(rawValue: sexID)! }
        set { sexID = newValue.rawValue }
    }
}
