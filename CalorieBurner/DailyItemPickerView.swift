//
//  DailyItemPickerView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 27/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

protocol DailyItemUnitDataSource {
    associatedtype Item: Hashable
    typealias UnitBounds = (min: Double, max: Double)
    typealias Bounds = [Item: UnitBounds]
    typealias Steppers = [Item : [Double]]
    
    var steppersPerUnit: [Item : [Double]] { get }
    var bounds: [Item : UnitBounds] { get }
    var currentUnit: Item { get set }
    var steps: [[Double]] { get set }
    
    func indexOfClosest(value atIndex: Int, from sourceIndex: Int, to destinationIndex: Int) -> Int
}

extension DailyItemUnitDataSource {
    func indexOfClosest(value atIndex: Int, from sourceIndex: Int, to destinationIndex: Int) -> Int {
        let previousStepperCount = steps[sourceIndex].count
        let currentStepperCount = steps[destinationIndex].count
        let scalingFactor = Double(currentStepperCount) / Double(previousStepperCount)
        let newIndex = Double(atIndex) * scalingFactor
        
        return Int(newIndex.rounded())
    }
}

final class DailyMassPickerDataSource: DailyItemUnitDataSource {
    let steppersPerUnit: [UnitMass : [Double]]
    let bounds: [UnitMass : UnitBounds]
    
    var stepper: [Double]
    var steps: [[Double]]
    var currentUnit: UnitMass {
        didSet {
            let (min, max) = bounds[currentUnit]!
            stepper = steppersPerUnit[currentUnit]!
            steps = stepper.map { [Double](stride(from: min, through: max, by: $0)) }
        }
    }
    
    private init() {
        steppersPerUnit = [
            .kilograms : [0.25, 0.5, 1, 2.5, 5, 10],
            .pounds : [1, 2.5, 5, 10, 25, 50],
            .stones : [0.25, 0.5, 1, 2.5, 5, 10]
        ]
        bounds = [
            .kilograms : (40, 250),
            .pounds : (100, 800),
            .stones : (6, 60)
        ]
        currentUnit = UserDefaults.standard.mass ?? .kilograms
        stepper = steppersPerUnit[currentUnit]!
        
        let (min, max) = bounds[currentUnit]!
        steps = stepper.map { [Double](stride(from: min, through: max, by: $0)) }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(unitDidChange(_:)),
            name: .UnitMassChanged,
            object: nil
        )
    }
    
    @objc private func unitDidChange(_ sender: Any) {
        guard let unit = UserDefaults.standard.mass else { return }
        currentUnit = unit
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    static let shared = DailyMassPickerDataSource()
    
}

final class DailyEnergyPickerDataSource: DailyItemUnitDataSource {
    let steppersPerUnit: [UnitEnergy : [Double]]
    let bounds: [UnitEnergy : UnitBounds]
    
    var stepper: [Double]
    var steps: [[Double]]
    var currentUnit: UnitEnergy {
        didSet {
            let (min, max) = bounds[currentUnit]!
            stepper = steppersPerUnit[currentUnit]!
            steps = stepper.map { [Double](stride(from: min, through: max, by: $0)) }
        }
    }
    
    private init() {
        steppersPerUnit = [
            .kilocalories : [10, 25, 50, 100, 250, 500],
            .kilojoules : [100, 250, 500, 1_000, 2_500, 5_000]
        ]
        bounds = [
            .kilocalories : (1_000, 15_000),
            .kilojoules : (4_000, 60_000)
        ]
        currentUnit = UserDefaults.standard.energy ?? .kilocalories
        stepper = steppersPerUnit[currentUnit]!
        
        let (min, max) = bounds[currentUnit]!
        steps = stepper.map { [Double](stride(from: min, through: max, by: $0)) }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(unitDidChange(_:)),
            name: .UnitEnergyChanged,
            object: nil
        )
    }
    
    @objc private func unitDidChange(_ sender: Any) {
        guard let unit = UserDefaults.standard.energy else { return }
        currentUnit = unit
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    static let shared = DailyEnergyPickerDataSource()
    
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
    
    var selectedMass: Double {
        return DailyMassPickerDataSource.shared.steps[selectedStepper][selectedRow(inComponent: 1)]
//        return DailyItemMultipliers.massValues[selectedRow(inComponent: 1)]
    }
    
    var selectedStepper = 0 {
        didSet {
            let rowToBeSelected = DailyMassPickerDataSource.shared.indexOfClosest(
                value: selectedRow(inComponent: 1),
                from: oldValue, to: selectedStepper)
            selectRow(rowToBeSelected, inComponent: 1, animated: false)
        }
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
            return DailyMassPickerDataSource.shared.stepper.count
        } else {
            return DailyMassPickerDataSource.shared.steps[selectedStepper].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let multiplier = DailyMassPickerDataSource.shared.stepper[row]
//            let multiplier = DailyItemMultipliers.massMultipliers[row]
            return DailyMassPickerView.numberFormatter.string(from: multiplier as NSNumber)
        } else {
            let value = DailyMassPickerDataSource.shared.steps[selectedStepper][row]
//            let value = DailyItemMultipliers.massValues[row]
            return DailyMassPickerView.numberFormatter.string(from: value as NSNumber)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedStepper = row
//            DailyItemMultipliers.massSelectedMultiplier = row
            reloadComponent(1)
//            selectRow(1, inComponent: 1, animated: false)
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
    
    static var numberFormatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.maximumFractionDigits = 0
        fmt.numberStyle = .decimal
        
        return fmt
    }()
    
    var selectedEnergy: Double {
        return DailyEnergyPickerDataSource.shared.steps[selectedStepper][selectedRow(inComponent: 1)]
//        return DailyItemMultipliers.energyValues[selectedRow(inComponent: 1)]
    }
        
    var selectedStepper = 0 {
        didSet {
            let rowToBeSelected = DailyEnergyPickerDataSource.shared.indexOfClosest(
                value: selectedRow(inComponent: 1),
                from: oldValue, to: selectedStepper)
            selectRow(rowToBeSelected, inComponent: 1, animated: false)
        }
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
            return DailyEnergyPickerDataSource.shared.stepper.count
//            return DailyItemMultipliers.energyMultipliers.count
        } else {
            return DailyEnergyPickerDataSource.shared.steps[selectedStepper].count
//            return DailyItemMultipliers.energyValues.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let multiplier = DailyEnergyPickerDataSource.shared.stepper[row]
//            let multiplier = DailyItemMultipliers.energyMultipliers[row]
            return DailyEnergyPickerView.numberFormatter.string(from: multiplier as NSNumber)
        } else {
            let value = DailyEnergyPickerDataSource.shared.steps[selectedStepper][row]
//            let value = DailyItemMultipliers.energyValues[row]
            return DailyEnergyPickerView.numberFormatter.string(from: value as NSNumber)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedStepper = row
            reloadComponent(1)
        } else {
//            selectedEnergy = DailyItemMultipliers.energyValues[row]
            dailyDelegate?.dailyPicker(self, valueDidChangeTo: Double(selectedEnergy))
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
