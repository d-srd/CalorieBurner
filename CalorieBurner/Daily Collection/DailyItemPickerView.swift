//
//  DailyItemPickerView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 27/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

/// OBSOLETE: should not be used. Use a numerical keyboard input instead.
/// Provides two ranges of numerical values for mass/energy picker views.
/// The selected value in the first range is used as a step value for the second range.
final class DailyMeasurementPickerDataSource {
    typealias Bounds = (min: Double, max: Double)
    
    // basically just used to avoid messing with generics and covariants
    enum AssociatedUnit: Hashable {
        case mass(UnitMass)
        case energy(UnitEnergy)
    }
    
    // useful when the user switches units
    private var unit: AssociatedUnit {
        didSet {
            let (min, max) = bounds[unit]!
            incrementer = incrementers[unit]!
            allIncrements = incrementer.map { [Double](stride(from: min, through: max, by: $0)) }
        }
    }
    
    // all possible "steps" for a particular unit
    // e.g. it makes sense for kilograms to go up in increments of 0.25, 0.5, 1, 2.5, etc.
    private let incrementers: [AssociatedUnit : [Double]]
    
    // minimum and maximum values that make sense for a particular unit - e.g. min 40 kgs, max 250 kgs
    private let bounds: [AssociatedUnit : Bounds]
    
    var incrementer: [Double]
    var allIncrements: [[Double]]
    
    // default values provided in here
    init(_ item: MeasurementItems) {
        switch item {
        case .mass:
            self.unit = .mass(UserDefaults.standard.mass)
            
            self.incrementers = [
                .mass(.kilograms) : [0.25, 0.5, 1, 2.5, 5, 10],
                .mass(.pounds) : [1, 2.5, 5, 10, 25, 50],
                .mass(.stones) : [0.25, 0.5, 1, 2.5, 5, 10]
            ]
            self.bounds = [
                .mass(.kilograms) : (40, 250),
                .mass(.pounds) : (100, 800),
                .mass(.stones) : (6, 60)
            ]
            
        case .energy:
            self.unit = .energy(UserDefaults.standard.energy)
            
            self.incrementers = [
                .energy(.kilocalories) : [10, 25, 50, 100, 250, 500],
                .energy(.kilojoules) : [100, 250, 500, 1_000, 2_500, 5_000]
            ]
            self.bounds = [
                .energy(.kilocalories) : (1_000, 15_000),
                .energy(.kilojoules) : (4_000, 60_000)
            ]
        }
        
        let (min, max) = bounds[unit]!
        incrementer = incrementers[unit]!
        allIncrements = incrementer.map { [Double](stride(from: min, through: max, by: $0)) }
        
        switch item {
        case .mass:
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(unitMassDidChange(_:)),
                name: .UnitMassChanged,
                object: nil
            )
        case .energy:
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(unitEnergyDidChange(_:)),
                name: .UnitEnergyChanged,
                object: nil
            )
        }
    }
    
    // used when the value in the first range changes — we can approximate a value in the second range that was close to the previous value
    func indexOfClosest(value atIndex: Int, from sourceIndex: Int, to destinationIndex: Int) -> Int {
        let countOfPreviousValues = allIncrements[sourceIndex].count
        let countOfCurrentValues = allIncrements[destinationIndex].count
        let scalingFactor = Double(countOfCurrentValues) / Double(countOfPreviousValues)
        let newIndex = Double(atIndex) * scalingFactor
        
        return Int(newIndex.rounded())
    }
    
    @objc private func unitMassDidChange(_ sender: Any) {
        unit = .mass(UserDefaults.standard.mass)
    }
    
    @objc private func unitEnergyDidChange(_ sender: Any) {
        unit = .energy(UserDefaults.standard.energy)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    static let mass = DailyMeasurementPickerDataSource(.mass)
    static let energy = DailyMeasurementPickerDataSource(.energy)
}

protocol DailyItemPickerDelegate: class {
    func dailyPicker(_ picker: UIPickerView, valueDidChangeTo value: Double)
}

class DailyMassPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    static var numberFormatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.maximumFractionDigits = 2
        fmt.numberStyle = .decimal
        
        return fmt
    }()
    
    weak var dailyDelegate: DailyItemPickerDelegate?
    
    var currentIncrement = 0
    var currentMassIndex: Int {
        return selectedRow(inComponent: 1)
    }
    var currentMass: Double {
        return DailyMeasurementPickerDataSource.mass.allIncrements[currentIncrement][currentMassIndex]
    }
    
    private func getClosest(_ index: Int, from oldStepperIndex: Int, to currentStepperIndex: Int) -> Int {
        return DailyMeasurementPickerDataSource.mass.indexOfClosest(value: index, from: oldStepperIndex, to: currentStepperIndex)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        delegate = self
        dataSource = self
        showsSelectionIndicator = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return DailyMeasurementPickerDataSource.mass.incrementer.count
        } else {
            return DailyMeasurementPickerDataSource.mass.allIncrements[currentIncrement].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let increment = DailyMeasurementPickerDataSource.mass.incrementer[row]
            return DailyMassPickerView.numberFormatter.string(from: increment as NSNumber)
        } else {
            let value = DailyMeasurementPickerDataSource.mass.allIncrements[currentIncrement][row]
            return DailyMassPickerView.numberFormatter.string(from: value as NSNumber)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let newIndex = getClosest(selectedRow(inComponent: 1), from: currentIncrement, to: row)
            currentIncrement = row
            reloadComponent(1)
            selectRow(newIndex, inComponent: 1, animated: false)
        } else {
            dailyDelegate?.dailyPicker(self, valueDidChangeTo: currentMass)
        }
    }
}

class DailyEnergyPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    weak var dailyDelegate: DailyItemPickerDelegate?
    
    static var numberFormatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.maximumFractionDigits = 0
        fmt.numberStyle = .decimal
        
        return fmt
    }()
    
    private func getClosest(_ index: Int, from oldStepperIndex: Int, to currentStepperIndex: Int) -> Int {
        return DailyMeasurementPickerDataSource.energy.indexOfClosest(value: index, from: oldStepperIndex, to: currentStepperIndex)
    }
    
    var currentIncrement = 0
    var currentEnergyIndex: Int {
        return selectedRow(inComponent: 1)
    }
    var currentEnergy: Double {
        return DailyMeasurementPickerDataSource.energy.allIncrements[currentIncrement][currentEnergyIndex]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        delegate = self
        dataSource = self
        showsSelectionIndicator = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return DailyMeasurementPickerDataSource.energy.incrementer.count
        } else {
            return DailyMeasurementPickerDataSource.energy.allIncrements[currentIncrement].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let increment = DailyMeasurementPickerDataSource.energy.incrementer[row]
            return DailyEnergyPickerView.numberFormatter.string(from: increment as NSNumber)
        } else {
            let value = DailyMeasurementPickerDataSource.energy.allIncrements[currentIncrement][row]
            return DailyEnergyPickerView.numberFormatter.string(from: value as NSNumber)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let newIndex = getClosest(selectedRow(inComponent: 1), from: currentIncrement, to: row)
            currentIncrement = row
            reloadComponent(1)
            selectRow(newIndex, inComponent: 1, animated: false)
        } else {
            dailyDelegate?.dailyPicker(self, valueDidChangeTo: currentEnergy)
        }
    }
}
