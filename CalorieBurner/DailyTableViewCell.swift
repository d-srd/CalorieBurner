//
//  DailyTableViewCell.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 26/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

enum DailyItemType { case mass, energy }

protocol DailyCellDelegate: class {
    func didCancelEditing(cell: DailyTableViewCell, item: DailyItemType)
    func didEndEditing(cell: DailyTableViewCell, with value: Measurement<UnitMass>)
    func didEndEditing(cell: DailyTableViewCell, with value: Measurement<UnitEnergy>)
}

struct DailyItemMultipliers {
    // TODO: - make this not hardcoded
    
    static let massMultipliers = [0.25, 0.5, 1, 2.5, 5, 10]
    static var massSelectedMultiplier: Int? {
        didSet {
            guard let multiplier = massSelectedMultiplier else { return }
            massValues = [Double](stride(from: 40, through: 250, by: massMultipliers[multiplier]))
        }
    }
    static var massValues = [Double](stride(from: 40, through: 250, by: 1))
    
    static let energyMultipliers = [25.0, 50, 100, 250, 500]
    static var energySelectedMultiplier: Int? {
        didSet {
            guard let multiplier = energySelectedMultiplier else { return }
            energyValues = [Double](stride(from: 1000, through: 15000, by: energyMultipliers[multiplier]))
        }
    }
    static var energyValues = [Double](stride(from: 1000, through: 15000, by: 100))
}

protocol DailyViewModel {
    var massTextField: UITextField! { get set }
    var energyTextField: UITextField! { get set }
    
    var mass: Measurement<UnitMass>? { get set }
    var energy: Measurement<UnitEnergy>? { get set }
}

class DailyTableViewCell: UITableViewCell, DailyViewModel {
    
    private static let measurementFormatter: MeasurementFormatter = {
        let fmt = MeasurementFormatter()
        fmt.unitOptions = .providedUnit
        fmt.unitStyle = .medium

        return fmt
    }()
    
    private static let numberFormatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.maximumFractionDigits = 2
        fmt.numberStyle = .decimal

        return fmt
    }()

    weak var cellDelegate: DailyCellDelegate?
    
    // TODO: - clean this up
    
    var massPickerView: UIPickerView? {
        didSet {
            guard let picker = massPickerView else { return }

            picker.dataSource = self
            picker.delegate = self
            picker.showsSelectionIndicator = true

            massTextField.inputView = picker
        }
    }

    var massPickerToolbar: UIToolbar? {
        didSet {
            guard let toolbar = massPickerToolbar else { return }

            toolbar.barStyle = .default
            toolbar.isTranslucent = true
            toolbar.sizeToFit()
            toolbar.isUserInteractionEnabled = true

            let cancelButton = UIBarButtonItem(
                title: "Cancel",
                style: .plain,
                target: self,
                action: #selector(didCancelEditingMass(_:))
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
                action: #selector(didEndEditingMass(_:))
            )
            toolbar.setItems(
                [cancelButton, flexibleButton, nextButton],
                animated: false
            )

            massTextField.inputAccessoryView = toolbar
        }
    }

    var energyPickerView: UIPickerView? {
        didSet {
            guard let picker = energyPickerView else { return }

            picker.dataSource = self
            picker.delegate = self
            picker.showsSelectionIndicator = true

            energyTextField.inputView = picker
        }
    }

    var energyPickerToolbar: UIToolbar? {
        didSet {
            guard let toolbar = energyPickerToolbar else { return }

            toolbar.barStyle = .default
            toolbar.isTranslucent = true
            toolbar.sizeToFit()
            toolbar.isUserInteractionEnabled = true

            let cancelButton = UIBarButtonItem(
                title: "Cancel",
                style: .plain,
                target: self,
                action: #selector(didCancelEditingEnergy(_:))
            )
            let flexibleButton = UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: self,
                action: nil
            )
            let doneButton = UIBarButtonItem(
                title: "Done",
                style: .done,
                target: self,
                action: #selector(didEndEditingEnergy(_:))
            )
            toolbar.setItems(
                [cancelButton, flexibleButton, doneButton],
                animated: false
            )

            energyTextField.inputAccessoryView = toolbar
        }
    }
    
    @IBOutlet weak var massTextField: UITextField!
    @IBOutlet weak var energyTextField: UITextField!
    
    /// Makes the input views display "No data"
    public func setEmpty() {
        massTextField.text = "No data"
        energyTextField.text = "No data"
    }
    
    @objc private func didCancelEditingMass(_ sender: UIBarButtonItem) {
        endEditing(true)
        massBuffer = nil
        cellDelegate?.didCancelEditing(cell: self, item: .mass)
    }
    
    @objc private func didCancelEditingEnergy(_ sender: UIBarButtonItem) {
        endEditing(true)
        energyBuffer = nil
        cellDelegate?.didCancelEditing(cell: self, item: .energy)
    }
    
    @objc private func didEndEditingMass(_ sender: UIBarButtonItem) {
        endEditing(true)
        mass = massBuffer
        cellDelegate?.didEndEditing(cell: self, with: mass!)
        
        energyTextField.becomeFirstResponder()
    }
    
    @objc private func didEndEditingEnergy(_ sender: UIBarButtonItem) {
        endEditing(true)
        energy = energyBuffer
        cellDelegate?.didEndEditing(cell: self, with: energy!)
    }
    
    // TODO: - make units user selectable
    
    public var mass: Measurement<UnitMass>? {
        didSet {
            if let mass = mass {
                massTextField.text = DailyTableViewCell.measurementFormatter.string(from: mass)
            }
        }
    }
    private var massBuffer: Measurement<UnitMass>? {
        didSet {
            if let buffer = massBuffer {
                massTextField.text = DailyTableViewCell.measurementFormatter.string(from: buffer)
            } else if let mass = mass {
                massTextField.text = DailyTableViewCell.measurementFormatter.string(from: mass)
            } else {
                massTextField.text = "No data"
            }
        }
    }
    
    public var energy: Measurement<UnitEnergy>? {
        didSet {
            if let energy = energy {
                energyTextField.text = DailyTableViewCell.measurementFormatter.string(from: energy)
            }
        }
    }
    private var energyBuffer: Measurement<UnitEnergy>? {
        didSet {
            if let buffer = energyBuffer {
                energyTextField.text = DailyTableViewCell.measurementFormatter.string(from: buffer)
            } else if let energy = energy {
                energyTextField.text = DailyTableViewCell.measurementFormatter.string(from: energy)
            } else {
                massTextField.text = "No data"
            }
        }
    }
}

extension DailyTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == massPickerView {
            return component == 0 ? DailyItemMultipliers.massMultipliers.count : DailyItemMultipliers.massValues.count
        } else if pickerView == energyPickerView {
            return component == 0 ? DailyItemMultipliers.energyMultipliers.count : DailyItemMultipliers.energyValues.count
        }

        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == massPickerView {
            if component == 0 {
                return DailyTableViewCell.numberFormatter.string(from: DailyItemMultipliers.massMultipliers[row] as NSNumber)
            }

            return DailyTableViewCell.numberFormatter.string(from: DailyItemMultipliers.massValues[row] as NSNumber)
        } else if pickerView == energyPickerView {
            if component == 0 {
                return DailyTableViewCell.numberFormatter.string(from: DailyItemMultipliers.energyMultipliers[row] as NSNumber)
            }

            return DailyTableViewCell.numberFormatter.string(from: DailyItemMultipliers.energyValues[row] as NSNumber)
        }

        return "Pero kvržica" // wtf
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            if pickerView == massPickerView {
                DailyItemMultipliers.massSelectedMultiplier = row
                massPickerView?.reloadComponent(1)
            } else if pickerView == energyPickerView {
                energyPickerView?.reloadComponent(1)
                DailyItemMultipliers.energySelectedMultiplier = row
            }
        } else if component == 1 {
            if pickerView == massPickerView {
                massBuffer = Measurement<UnitMass>(value: DailyItemMultipliers.massValues[row], unit: .kilograms)
            } else if pickerView == energyPickerView {
                energyBuffer = Measurement<UnitEnergy>(value: Double(DailyItemMultipliers.energyValues[row]), unit: .kilocalories)
            }
        }
    }
}

