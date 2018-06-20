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

public final class MockUser: UserRepresentable {
    var activityLevel: ActivityLevel
    
    var age: Int16
    
    var height: Double
    
    var weight: Double
    
    var sex: Sex
    
    init(activityLevel: ActivityLevel, age: Int16, height: Double, weight: Double, sex: Sex) {
        self.activityLevel = activityLevel
        self.age = age
        self.height = height
        self.weight = weight
        self.sex = sex
    }
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
