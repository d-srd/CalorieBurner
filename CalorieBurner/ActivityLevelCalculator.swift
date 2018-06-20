//
//  ActivityLevelCalculator.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 20/06/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation

class ActivityLevelCalculator {
    
    // reference: https://link.springer.com/article/10.2165%2F00007256-200434010-00001
    private static let activityLevelPerStepCount = [
        ActivityLevel.sedentary : (    0,   4_999),
        ActivityLevel.light     : ( 5_000,  7_499),
        ActivityLevel.moderate  : ( 7_500,  9_999),
        ActivityLevel.heavy     : (10_000, 12_499),
        ActivityLevel.extreme   : (12_500, 50_000)
    ]
    
    static func getActivityLevel(forStepCount stepCount: Int) -> ActivityLevel? {
        if let activityLevelIndex = activityLevelPerStepCount.values.index(where: { ($0.0..<$0.1).contains(stepCount) }) {
            return activityLevelPerStepCount.keys[activityLevelIndex]
        }
        
        return nil
    }
}
