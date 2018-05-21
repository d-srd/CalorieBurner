//
//  CalorieBrainStaticTDEETests.swift
//  CalorieBurnerTests
//
//  Created by Dino Srdoč on 21/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import XCTest
@testable import CalorieBurner

// based on https://en.wikipedia.org/wiki/Harris–Benedict_equation
//
//
// Men BMR = 88.362 + (13.397 × weight in kg) + (4.799 × height in cm) - (5.677 × age in years)
// Women BMR = 447.593 + (9.247 × weight in kg) + (3.098 × height in cm) - (4.330 × age in years)
//

struct MockProfile: UserRepresentable {
    var activityLevel: ActivityLevel
    var age: Int16
    var height: Double
    var sex: Sex
}

class CalorieBrainStaticTDEETests: XCTestCase {
    var brain: CalorieBrain!
    
    override func setUp() {
        super.setUp()
        
        brain = CalorieBrain()
    }
    
    override func tearDown() {
        brain = nil
        
        super.tearDown()
    }
    
    func testMaleBMR() {
        let profiles = [
            MockProfile(activityLevel: .sedentary,
                        age: 20,
                        height: 180,
                        sex: .male),
            MockProfile(activityLevel: .light,
                        age: 30,
                        height: 170,
                        sex: .male),
            MockProfile(activityLevel: .heavy,
                        age: 18,
                        height: 190,
                        sex: .male),
            MockProfile(activityLevel: .sedentary,
                        age: 18,
                        height: 190,
                        sex: .male)
        ]
        
        let bmrs = profiles.map(brain.calculateBMR)
        
        XCTAssertEqual(bmrs[3], bmrs[2], "Activity level should not change BMR")
    }
}
