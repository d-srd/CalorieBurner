//
//  CalorieBrainTests.swift
//  CalorieBurnerTests
//
//  Created by Dino Srdoč on 20/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import XCTest
@testable import CalorieBurner

class CalorieBrainTDEETests: XCTestCase {
    
    var brain: CalorieBrain!
    
    override func setUp() {
        super.setUp()
        
        brain = CalorieBrain()
    }
    
    override func tearDown() {
        brain = nil
        
        super.tearDown()
    }
    
    func testConstantMassAndEnergyValues() {
        let week0 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 10))!.startOfWeek!
        let week1 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 17))!.startOfWeek!
        
        // if we consume 2500 calories every day and maintain mass, our TDEE is most likely 2500 calories
        let value = (averageMass: 75.0, totalEnergy: 2500.0 * 7)
        
        let weeks: Weeks = [
            week0: value,
            week1: value
        ]
        
        let tdee = brain.calculateTDEE(from: weeks)
        
        XCTAssertEqual(tdee, 2500.0, "No change in mass/energy should make the base energy value be the TDEE value")
    }
    
    func testNoInputValues() {
        let weeks = Weeks()
        let tdee = brain.calculateTDEE(from: weeks)
        
        XCTAssertNil(tdee, "No input values should produce no output values")
    }
    
    func testWeightLoss() {
        let week0 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 03))!.startOfWeek!
        let week1 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 10))!.startOfWeek!
        let week2 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 17))!.startOfWeek!
        let week3 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 24))!.startOfWeek!
        
        let value0 = (averageMass: 90.0, totalEnergy: 2500.0 * 7)
        let value1 = (averageMass: 85.0, totalEnergy: 2000.0 * 7)
        let value2 = (averageMass: 80.0, totalEnergy: 2000.0 * 7)
        let value3 = (averageMass: 75.0, totalEnergy: 1925.0 * 7)
        
        let weeks: Weeks = [
            week0: value0, week1: value1,
            week2: value2, week3: value3
        ]
        
        let tdee = brain.calculateTDEE(from: weeks)
        
        XCTAssertEqual(tdee, (2500.0 + 3000.0) / 2, "Should be kinda similar I guess")
    }
    
}
