//
//  TodayViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 17/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

fileprivate let measurementFormatter: MeasurementFormatter = {
    let fmt = MeasurementFormatter()
    fmt.unitOptions = .providedUnit
    return fmt
}()

class HomeViewController: UIViewController {
    @IBOutlet weak var tdeeLabel: UILabel!
    
    let startDate = Calendar.current.date(from: DateComponents(year: 2018, month: 01, day: 01))!
    let endDate = Date()
    
    lazy var mediator = TDEEMediator(context: CoreDataStack.shared.viewContext, startDate: startDate, endDate: endDate)
    let brain = CalorieBrain()
    
    private var energyUnit: UnitEnergy = UserDefaults.standard.energy
    private var massUnit: UnitMass = UserDefaults.standard.mass
    
    private var tdee: Energy? {
        let transformed = mediator.transformDailies()
        let value = brain.calculateTDEE(from: transformed)
        return value.map { Energy(value: $0, unit: .kilocalories).converted(to: energyUnit) }
    }
    
//    private var weeklyMassDelta: Double? {
//
//    }
    
    @IBAction func updateStuff(_ sender: Any) {
        print("update")
        print(mediator.averageMass())
        print(mediator.sumEnergy())
        
        let transformed = mediator.transformDailies()
        let tdee = brain.calculateTDEE(from: transformed)
//        let tdee = brain.calculateTDEE(with: try! CoreDataStack.shared.fetchAll())
        print("tdee: ", tdee)
    }
    
    private func updateTDEELabel() {
        tdeeLabel.text = tdee.map(measurementFormatter.string)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTDEELabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(unitsDidChange(_:)),
                                               name: .UnitMassChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(unitsDidChange(_:)),
                                               name: .UnitEnergyChanged,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UnitMassChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UnitEnergyChanged, object: nil)
    }
    
    @objc private func unitsDidChange(_ sender: Any) {
        energyUnit = UserDefaults.standard.energy
        massUnit = UserDefaults.standard.mass
        
        updateTDEELabel()
    }
}
