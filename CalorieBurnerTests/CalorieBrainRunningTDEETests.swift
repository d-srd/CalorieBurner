//
//  CalorieBrainTests.swift
//  CalorieBurnerTests
//
//  Created by Dino Srdoč on 20/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import XCTest
@testable import CalorieBurner

class CalorieBrainRunningTDEETests: XCTestCase {
    
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
//        let value = (averageMass: 75.0, totalEnergy: 2500.0 * 7)
        
        let weeks: [Week] = [
            Week(start: week0, masses: Array(repeating: 85, count: 7), energies: Array(repeating: 2500, count: 7)),
            Week(start: week1, masses: Array(repeating: 85, count: 7), energies: Array(repeating: 2500, count: 7))
        ]
        
        let tdee = brain.calculateTDEE(using: weeks)
        
        XCTAssertEqual(tdee!, 2500.0, accuracy: 0.0001, "No change in mass/energy should make the base energy value be the TDEE value")
    }
    
    func testNoInputValues() {
        let weeks = [Week]()
        let tdee = brain.calculateTDEE(using: weeks)
        
        XCTAssertNil(tdee, "No input values should produce no output values")
    }
    
    func testWeightLoss() {
        let week0 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 03))!.startOfWeek!
        let week1 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 10))!.startOfWeek!
        let week2 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 17))!.startOfWeek!
        let week3 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 24))!.startOfWeek!
        let energies = [2200, 2152.4, 2100, 2180, 2220, 2160, 2200]
        
        let weeks = [
            Week(start: week0, masses: [90, 90, 89.5, 89, 86.5, 88, 88.25], energies: energies),
            Week(start: week1, masses: [87.5, 87, 86.5, 87.85, 89, 87, 86], energies: energies),
            Week(start: week2, masses: [85, 83.2, 84, 84.5, 84, 83.5, 83], energies: energies),
            Week(start: week3, masses: [81, 82.5, 82.75, 82, 82.5, 82.5, 82.125], energies: energies)
        ]
        
        let tdee = brain.calculateTDEE(using: weeks)!
        
        XCTAssertGreaterThan(tdee, 2200.0, "TDEE should be greater than the average calorie consumption")
    }
    
    func testLinearGain() {
        let week0 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 03))!.startOfWeek!
        let week1 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 10))!.startOfWeek!
        let week2 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 17))!.startOfWeek!
        let week3 = Calendar.current.date(from: DateComponents(year: 2018, month: 04, day: 24))!.startOfWeek!
        
        let weeks = [
            Week(start: week0, masses: Array(repeating: 75.0, count: 7), energies: Array(repeating: 3300, count: 7)),
            Week(start: week1, masses: Array(repeating: 80, count: 7), energies: Array(repeating: 3400, count: 7)),
            Week(start: week2, masses: Array(repeating: 85.0, count: 7), energies: Array(repeating: 3500, count: 7)),
            Week(start: week3, masses: Array(repeating: 90, count: 7), energies: Array(repeating: 3600, count: 7))
        ]

        let tdee = brain.calculateTDEE(using: weeks)!

        XCTAssertEqual(tdee, 3450, accuracy: 0.0001, "TDEE should be equal to the average calorie consumption over the weeks")
    }
    
}
