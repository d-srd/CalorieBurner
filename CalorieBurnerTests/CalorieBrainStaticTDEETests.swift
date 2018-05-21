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
    var weight: Double
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
    
    // i don't like this test. smells fishy.
    let calories: (MockProfile, Bool) -> Double? = { profile, isMale in
        guard 0 < profile.age, profile.age < 150,
              55 < profile.height, profile.height < 275,
              30 < profile.weight, profile.weight < 350
        else { return nil }
        
        let constant, weight, height, age: Double
        
        if isMale {
            constant = 88.362
            weight = 13.397 * profile.weight
            height = 4.799 * profile.height
            age = 5.677 * Double(profile.age)
        } else {
            constant = 447.593
            weight = 9.247 * profile.weight
            height = 3.098 * profile.height
            age = 4.330 * Double(profile.age)
        }
        
        return constant + weight + height - age
    }
    
    func testValidBMR() {
        let maleProfiles = [
            MockProfile(activityLevel: .sedentary,
                        age: 20,
                        height: 180,
                        weight: 90,
                        sex: .male),
            MockProfile(activityLevel: .light,
                        age: 20,
                        height: 180,
                        weight: 90,
                        sex: .male),
            MockProfile(activityLevel: .extreme,
                        age: 20,
                        height: 190,
                        weight: 90,
                        sex: .male),
            MockProfile(activityLevel: .extreme,
                        age: 20,
                        height: 190,
                        weight: 110,
                        sex: .male),
        ]
        
        let maleBMRs = maleProfiles.map(brain.calculateBMR)
        
        for bmr in maleBMRs {
            XCTAssertNotNil(bmr, "Valid input should have valid output")
        }
        
        XCTAssertEqual(maleBMRs[0]!,
                       maleBMRs[1]!,
                       accuracy: 0.0001,
                       "Activity level should not change BMR")
        XCTAssertEqual(maleBMRs[0]!,
                       calories(maleProfiles[0], true)!,
                       accuracy: 0.0001,
                       "Calories should match up with this function")
        XCTAssertGreaterThan(maleBMRs[2]!,
                             maleBMRs[1]!,
                             "A taller person needs more calories")
        XCTAssertGreaterThan(maleBMRs[3]!,
                             maleBMRs[2]!,
                             "A heavier person needs more calories")
        
    }
    
    func testInvalidBMR() {
        let profiles = [
            MockProfile(activityLevel: .extreme,
                        age: -5,
                        height: 110,
                        weight: 110,
                        sex: .male),
            MockProfile(activityLevel: .extreme,
                        age: 300,
                        height: 190,
                        weight: 110,
                        sex: .male),
            MockProfile(activityLevel: .extreme,
                        age: 0,
                        height: 190,
                        weight: 110,
                        sex: .male),
            MockProfile(activityLevel: .extreme,
                        age: 20,
                        height: 1515313,
                        weight: 110,
                        sex: .male),
            MockProfile(activityLevel: .extreme,
                        age: 20,
                        height: 190,
                        weight: -55,
                        sex: .male)
        ]
        let bmrs = profiles.map(brain.calculateBMR)
        
        for bmr in bmrs {
            XCTAssertNil(bmr, "Invalid input should result in invalid output")
        }
    }
    
    
}
