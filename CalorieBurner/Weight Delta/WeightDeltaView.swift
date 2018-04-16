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
            updateProgressView(animated: false)
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
            updateProgressView(animated: true)
        }
    }
    private var initialMass: Mass? {
        return delegate?.startingWeight(self)
    }
    private var currentMass: Mass? {
        return delegate?.currentWeight(self)
    }
    
    var animationDuration = 0.4
    
    // IM = 70
    // CM = 75
    // GM = 80
    // completion = 50%
    //
    // IM = 90
    // CM = 85
    // GM = 80
    // completion = 50%
    //
    // IM = 90
    // CM = 95
    // GM = 80
    // completion = 0%
    //
    // IM = 70
    // CM = 65
    // GM = 80
    // completion = 0%
    private func updateProgressView(animated: Bool) {
        if let initialMass = initialMass, let currentMass = currentMass, let goalMass = goalMass {
            let completion = abs((currentMass.value - initialMass.value)) / abs((goalMass.value - initialMass.value))
            
            if animated {
                UIView.animate(withDuration: animationDuration) {
                    self.progressView.progress = CGFloat(completion)
                }
            } else {
                progressView.progress = CGFloat(completion)
            }
        }
    }
    
    func reloadData() {
        if let currentMass = currentMass {
            currentWeightLabel.text = measurementFormatter.string(from: currentMass)
        }
        
        updateProgressView(animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        goalWeightTextField.inputView = {
            let picker = DailyMassPickerView()
            picker.dailyDelegate = self
            
            return picker
        }()
        
        goalWeightTextField.inputAccessoryView = {
            let toolbar = DailyMassPickerToolbar()
            toolbar.dailyDelegate = self
            
            // the default title is "next" because the toolbar is used as an input accessory view in
            // daily collection view and there is another picker view right after it
            toolbar.items?.last?.title = "Done"
            
            return toolbar
        }()
        
        reloadData()
    }
}

extension WeightDeltaView: DailyItemPickerDelegate {
    func dailyPicker(_ picker: UIPickerView, valueDidChangeTo value: Double) {
        goalMassBuffer = Mass(value: value, unit: UserDefaults.standard.mass)
    }
}

extension WeightDeltaView: DailyToolbarDelegate {
    func didCancelEditing(_ type: MeasurementItems) {
        endEditing(true)
        goalMassBuffer = nil
    }
    
    func didEndEditing(_ type: MeasurementItems) {
        endEditing(true)
        goalMass = goalMassBuffer
    }
}
