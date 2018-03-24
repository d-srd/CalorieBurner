//
//  WeightDeltaView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 23/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import CocoaControls

protocol WeightDeltaDelegate: class {
    func startingWeight(_ weightDeltaView: WeightDeltaView) -> Mass
    func currentWeight(_ weightDeltaView: WeightDeltaView) -> Mass
    func initialGoalWeight(_ weightDeltaView: WeightDeltaView) -> Mass
    func goalWeightDidChange(_ weightDeltaView: WeightDeltaView, to value: Mass)
}

class WeightDeltaView: UIView {
    @IBOutlet weak var progressView: CircleProgressView! {
        didSet {
            updateProgressView()
        }
    }
    @IBOutlet weak var currentWeightLabel: UILabel! {
        didSet {
            if let mass = currentMass {
               currentWeightLabel.text = measurementFormatter.string(from: mass)
            }
        }
    }
    @IBOutlet weak var goalWeightTextField: UITextField! {
        didSet {
            goalWeightTextField.inputView = massPickerView
            goalWeightTextField.inputAccessoryView = massPickerToolbar
        }
    }
    private var massPickerView: DailyMassPickerView?
    private var massPickerToolbar: DailyMassPickerToolbar?
    
    weak var delegate: WeightDeltaDelegate? {
        didSet {
            if let initialGoal = delegate?.initialGoalWeight(self) {
                goalWeightTextField.text = measurementFormatter.string(from: initialGoal)
            }
        }
    }
    
    private let measurementFormatter: MeasurementFormatter = {
        let fmt = MeasurementFormatter()
        fmt.unitOptions = .providedUnit
        let numFmt = NumberFormatter()
        numFmt.numberStyle = .decimal
        numFmt.maximumFractionDigits = 2
        fmt.numberFormatter = numFmt
        
        return fmt
    }()
    private var goalMassBuffer: Mass? {
        didSet {
            if let massBuffer = goalMassBuffer {
                goalWeightTextField.text = measurementFormatter.string(from: massBuffer)
            } else {
                goalWeightTextField.text = nil
            }
        }
    }
    private(set) var goalMass: Mass? {
        didSet {
            if let goalMass = goalMass {
                delegate?.goalWeightDidChange(self, to: goalMass)
            }
            updateProgressView()
        }
    }
    var initialMass: Mass? {
        return delegate?.startingWeight(self)
    }
    var currentMass: Mass? {
        return delegate?.currentWeight(self)
    }
    
    private func updateProgressView() {
        if let initialMass = initialMass, let currentMass = currentMass, let goalMass = goalMass {
            let completion = (currentMass.value - initialMass.value) / (goalMass.value - initialMass.value)
            progressView.progress = CGFloat(completion)
        }
    }
    
    func reloadData() {
        if let currentMass = currentMass {
            currentWeightLabel.text = measurementFormatter.string(from: currentMass)
        }
        
        if let goalMass = goalMass, let currentMass = currentMass {
            let completion = currentMass.value / goalMass.value
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.progressView.progress = CGFloat(completion)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        massPickerView = DailyMassPickerView()
        massPickerToolbar = DailyMassPickerToolbar()
        
        massPickerView?.dailyDelegate = self
        massPickerToolbar?.dailyDelegate = self
        massPickerToolbar?.items?.last?.title = "Done"
        
        goalWeightTextField.inputView = massPickerView
        goalWeightTextField.inputAccessoryView = massPickerToolbar
        
        reloadData()
    }
}

extension WeightDeltaView: DailyItemPickerDelegate {
    func dailyPicker(_ picker: UIPickerView, valueDidChangeTo value: Double) {
        goalMassBuffer = Mass(value: value, unit: UserDefaults.standard.mass ?? .kilograms)
    }
}

extension WeightDeltaView: DailyToolbarDelegate {
    func didCancelEditing(_ type: DailyItemType) {
        endEditing(true)
        goalMassBuffer = nil
    }
    
    func didEndEditing(_ type: DailyItemType) {
        endEditing(true)
        goalMass = goalMassBuffer
    }
}
