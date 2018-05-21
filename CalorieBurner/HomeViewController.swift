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
    fmt.numberFormatter.maximumFractionDigits = 1
    fmt.numberFormatter.roundingMode = .halfUp
    fmt.numberFormatter.roundingIncrement = 0.1
    return fmt
}()

class HomeViewController: UIViewController {
    @IBOutlet weak var tdeeLabel: UILabel!
    @IBOutlet weak var deltaMassLabel: UILabel!
    @IBOutlet weak var deltaEnergyLabel: UILabel!
    
    let startDate = Calendar.current.date(from: DateComponents(year: 2018, month: 01, day: 01))!
    let endDate = Date()
    
    lazy var mediator = TDEEMediator(context: CoreDataStack.shared.viewContext, startDate: startDate, endDate: endDate)
    let brain = CalorieBrain()
    
    private var energyUnit: UnitEnergy = UserDefaults.standard.energy
    private var massUnit: UnitMass = UserDefaults.standard.mass
    
    private var weeklyEntries: [Week] {
        return mediator.transformDailies()
    }
    
    private var tdee: Energy? {
        let value = brain.calculateTDEE(from: weeklyEntries)
        return value.map { Energy(value: $0, unit: .kilocalories).converted(to: energyUnit) }
    }
    
    private var deltaMass: Mass? {
        let value =  brain.calculateDelta(.mass, from: weeklyEntries)
        return value.map { Mass(value: $0, unit: .kilograms).converted(to: massUnit) }
    }
    
    private var deltaEnergy: Energy? {
        let value = brain.calculateDelta(.energy, from: weeklyEntries)
        return value.map { Energy(value: $0, unit: .kilocalories).converted(to: energyUnit) }
    }
    
    private func updateTDEELabel() {
        tdeeLabel.text = tdee.map(measurementFormatter.string)
    }
    
    private func updateDeltaLabel<T>(_ label: UILabel, measurement: Measurement<T>?) {
        guard let measurement = measurement else { return }
        
        switch measurement.value {
        case ..<0:
            label.textColor = UIColor.green
        case 0:
            label.textColor = UIColor.cyan
        case 0...:
            label.textColor = UIColor.red
        default: fatalError("wtf")
        }
        
        label.text = measurementFormatter.string(from: measurement)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTDEELabel()
        updateDeltaLabel(deltaMassLabel, measurement: deltaMass)
        updateDeltaLabel(deltaEnergyLabel, measurement: deltaEnergy)
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
        updateDeltaLabel(deltaMassLabel, measurement: deltaMass)
        updateDeltaLabel(deltaEnergyLabel, measurement: deltaEnergy)
    }
}
