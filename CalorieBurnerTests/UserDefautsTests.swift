//
//  UserDefautsTests.swift
//  CalorieBurnerTests
//
//  Created by Dino Srdoč on 29/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import XCTest
@testable import CalorieBurner

class UserDefautsTests: XCTestCase {
    
    var userDefaults: UserDefaults?
    let mockStorageName = "MockDefaults"
    
    override func setUp() {
        super.setUp()
        
        userDefaults = UserDefaults(suiteName: mockStorageName)
    }
    
    override func tearDown() {
        userDefaults?.removeSuite(named: mockStorageName)
        super.tearDown()
    }
    
    func testDefaults() {
        XCTAssertNotNil(userDefaults, "User Defaults should not be nil after initialization")
    }
    
    func testMassStorage() {
        let units: [UnitMass] = [.kilograms, .carats, .metricTons, .ounces, .slugs, .stones]
        
        for unit in units {
            userDefaults?.mass = unit
            XCTAssertNotNil(userDefaults?.mass, "Mass should be initialized")
            XCTAssertEqual(unit, userDefaults?.mass, "Set unit should be the same as the unit stored in User Defaults")
        }
    }
    
    func testEnergyStorage() {
        let units: [UnitEnergy] = [.kilocalories, .kilojoules, .kilowattHours]
        
        for unit in units {
            userDefaults?.energy = unit
            XCTAssertNotNil(userDefaults?.energy, "Energy should be initialized")
            XCTAssertEqual(unit, userDefaults?.energy, "Set unit should be the same as the unit stored in User Defaults")
        }
    }
    
    
}
