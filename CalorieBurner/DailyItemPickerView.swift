//
//  DailyItemPickerView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 27/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

// TODO: - make this a bit less... stupid
/// Used for DailyPickerView datasource and delegate methods
class DailyItemMultipliers {
    // TODO: - make this not hardcoded
    typealias UnitBounds = (min: Double, max: Double)

    static let unitMassMultipliers: [UnitMass : [Double]] = [
        .kilograms : [0.25, 0.5, 1, 2.5, 5, 10],
        .pounds : [1, 2.5, 5, 10, 25, 50],
        .stones : [0.25, 0.5, 1, 2.5, 5, 10]
    ]
    static let unitMassBounds: [UnitMass : UnitBounds] = [
        .kilograms : (40, 250),
        .pounds : (100, 800),
        .stones : (6, 60)
    ]
    static let defaultMassValues: [UnitMass : [Double]] = [
        .kilograms : [Double](stride(from: 40, through: 250, by: 5)),
        .pounds : [Double](stride(from: 100, through: 800, by: 25)),
        .stones : [Double](stride(from: 6, through: 60, by: 1))
    ]
    
    static var massMultipliers = unitMassMultipliers[.kilograms]!
    static var massSelectedMultiplier = 1 {
        didSet {
            let (min, max) = unitMassBounds[massUnit]!
            let multiplier = massMultipliers[massSelectedMultiplier]
            massValues = [Double](stride(from: min, through: max, by: multiplier))
        }
    }
    static var massValues = defaultMassValues[.kilograms]!
    
    static var massUnit = UnitMass.kilograms {
        didSet {
            switch massUnit {
            case .kilograms:
                massMultipliers = unitMassMultipliers[.kilograms]!
                massValues = defaultMassValues[.kilograms]!
            case .pounds:
                massMultipliers = unitMassMultipliers[.pounds]!
                massValues = defaultMassValues[.pounds]!
            case .stones:
                massMultipliers = unitMassMultipliers[.stones]!
                massValues = defaultMassValues[.stones]!
            default:
                fatalError("unsupported mass unit")
            }
        }
    }
    
    static let unitEnergyMultipliers: [UnitEnergy : [Double]] = [
        .kilocalories : [10, 25, 50, 100, 250, 500],
        .kilojoules : [100, 250, 500, 1_000, 2_500, 5_000]
    ]
    static let unitEnergyBounds: [UnitEnergy : UnitBounds] = [
        .kilocalories : (1_000, 15_000),
        .kilojoules : (4_000, 60_000)
    ]
    static let defaultEnergyValues: [UnitEnergy : [Double]] = [
        .kilocalories : [Double](stride(from: 1_000, through: 15_000, by: 250)),
        .kilojoules : [Double](stride(from: 4_000, through: 60_000, by: 1_000))
    ]
    
    static var energyMultipliers = unitEnergyMultipliers[.kilocalories]!
    static var energySelectedMultiplier = 1 {
        didSet {
            let (min, max) = unitEnergyBounds[energyUnit]!
            let multiplier = energyMultipliers[energySelectedMultiplier]
            energyValues = [Double](stride(from: min, through: max, by: multiplier))
        }
    }
    static var energyValues = defaultEnergyValues[.kilocalories]!
    
    static var energyUnit = UnitEnergy.kilocalories {
        didSet {
            print(energyUnit)
            switch energyUnit {
            case .kilojoules:
                energyMultipliers = unitEnergyMultipliers[.kilojoules]!
                energyValues = defaultEnergyValues[.kilojoules]!
            case .kilocalories:
                energyMultipliers = unitEnergyMultipliers[.kilocalories]!
                energyValues = defaultEnergyValues[.kilocalories]!
            default:
                fatalError("unsupported energy unit")
            }
        }
    }
    
    static var numberFormatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.maximumFractionDigits = 2
        fmt.numberStyle = .decimal
        
        return fmt
    }()
}

protocol DailyItemPickerDelegate: class {
    func dailyPicker(_ picker: UIPickerView, valueDidChangeTo value: Double)
}

class DailyMassPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    weak var dailyDelegate: DailyItemPickerDelegate?
    
    var selectedMass: Double {
        return DailyItemMultipliers.massValues[selectedRow(inComponent: 1)]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UnitMassChanged, object: nil)
    }
    
    func commonInit() {
        delegate = self
        dataSource = self
        showsSelectionIndicator = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(massUnitDidChange(_:)),
            name: .UnitMassChanged,
            object: nil
        )
    }
    
    @objc func massUnitDidChange(_ sender: Any) {
        guard let mass = UserDefaults.standard.mass
//            let energySymbol = UserDefaults.standard.string(forKey: "energyUnit")
            else { return }
//        let newMassUnit = UnitMass(symbol: massSymbol)
//        let newEnergyUnit = UnitEnergy(symbol: energySymbol)
//
        DailyItemMultipliers.massUnit = mass
        reloadAllComponents()
//        energyUnit = newEnergyUnit
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return DailyItemMultipliers.massMultipliers.count
        } else {
            return DailyItemMultipliers.massValues.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let multiplier = DailyItemMultipliers.massMultipliers[row]
            return DailyItemMultipliers.numberFormatter.string(from: multiplier as NSNumber)
        } else {
            let value = DailyItemMultipliers.massValues[row]
            return DailyItemMultipliers.numberFormatter.string(from: value as NSNumber)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            DailyItemMultipliers.massSelectedMultiplier = row
            reloadComponent(1)
        } else {
            dailyDelegate?.dailyPicker(self, valueDidChangeTo: selectedMass)
        }
    }
}

@objc protocol DailyToolbarDelegate: class {
    @objc optional func didCancelEditing(_ type: DailyItemType)
    @objc optional func didEndEditing(_ type: DailyItemType)
}

class DailyMassPickerToolbar: UIToolbar {
    weak var dailyDelegate: DailyToolbarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    @objc private func didCancelEditing(_ sender: AnyObject) {
        dailyDelegate?.didCancelEditing?(.mass)
    }
    
    @objc private func didEndEditing(_ sender: AnyObject) {
        dailyDelegate?.didEndEditing?(.mass)
    }
    
    func commonInit() {
        barStyle = .default
        isTranslucent = true
        sizeToFit()
        isUserInteractionEnabled = true
        
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didCancelEditing(_:))
        )
        let flexibleButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: self,
            action: nil
        )
        let nextButton = UIBarButtonItem(
            title: "Next",
            style: .done,
            target: self,
            action: #selector(didEndEditing(_:))
        )
        
        setItems(
            [cancelButton, flexibleButton, nextButton],
            animated: false
        )
    }
}

class DailyEnergyPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    weak var dailyDelegate: DailyItemPickerDelegate?
    
    var selectedEnergy: Double {
        return DailyItemMultipliers.energyValues[selectedRow(inComponent: 1)]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UnitEnergyChanged, object: nil)
    }
    
    func commonInit() {
        delegate = self
        dataSource = self
        showsSelectionIndicator = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(energyUnitDidChange(_:)),
            name: .UnitEnergyChanged,
            object: nil
        )
    }
    
    @objc func energyUnitDidChange(_ sender: Any) {
        guard let energy = UserDefaults.standard.energy else { return }
//        let newEnergyUnit = UnitEnergy(symbol: energySymbol)
        
        DailyItemMultipliers.energyUnit = energy
        reloadAllComponents()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return DailyItemMultipliers.energyMultipliers.count
        } else {
            return DailyItemMultipliers.energyValues.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let multiplier = DailyItemMultipliers.energyMultipliers[row]
            return DailyItemMultipliers.numberFormatter.string(from: multiplier as NSNumber)
        } else {
            let value = DailyItemMultipliers.energyValues[row]
            return DailyItemMultipliers.numberFormatter.string(from: value as NSNumber)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            DailyItemMultipliers.energySelectedMultiplier = row
            reloadComponent(1)
        } else {
//            selectedEnergy = DailyItemMultipliers.energyValues[row]
            dailyDelegate?.dailyPicker(self, valueDidChangeTo: selectedEnergy)
        }
    }
}

class DailyEnergyPickerToolbar: UIToolbar {
    weak var dailyDelegate: DailyToolbarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    @objc private func didCancelEditing(_ sender: AnyObject) {
        dailyDelegate?.didCancelEditing?(.energy)
    }
    
    @objc private func didEndEditing(_ sender: AnyObject) {
        dailyDelegate?.didEndEditing?(.energy)
    }
    
    func commonInit() {
        barStyle = .default
        isTranslucent = true
        sizeToFit()
        isUserInteractionEnabled = true
        
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didCancelEditing(_:))
        )
        let flexibleButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: self,
            action: nil
        )
        let nextButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(didEndEditing(_:))
        )
        
        setItems(
            [cancelButton, flexibleButton, nextButton],
            animated: false
        )
    }
}
