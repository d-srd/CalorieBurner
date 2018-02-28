//
//  DailyTableViewCell.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 26/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

protocol DailyCellDelegate: class {
    func didCancelEditing(cell: DailyTableViewCell, item: DailyTableViewCell.ItemType)
    func didEndEditing(cell: DailyTableViewCell, item: DailyTableViewCell.ItemType, value: Double)
}

class DailyTableViewCell: UITableViewCell {
    enum ItemType { case mass, energy }
    
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
    
    // TODO: - make this not hardcoded
    
    private static let massMultipliers = [0.25, 0.5, 1, 2.5, 5, 10]
    private static var massSelectedMultiplier: Int? {
        didSet {
            guard let multiplier = massSelectedMultiplier else { return }
            massValues = [Double](stride(from: 40, through: 250, by: massMultipliers[multiplier]))
        }
    }
    private static var massValues = [Double](stride(from: 40, through: 250, by: 1))

    private static let energyMultipliers = [25, 50, 100, 250, 500]
    private static var energySelectedMultiplier: Int? {
        didSet {
            guard let multiplier = energySelectedMultiplier else { return }
            energyValues = [Int](stride(from: 1000, through: 15000, by: energyMultipliers[multiplier]))
        }
    }
    private static var energyValues = [Int](stride(from: 1000, through: 15000, by: 100))

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
                action: #selector(setNextInput)
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
                action: #selector(didCancelEditing(_:))
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
                action: #selector(didEndEditing(_:))
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
    private var activeTextField: UITextField?
    
    /// Makes the input views display "No data"
    public func setEmpty() {
        massTextField.text = "No data"
        energyTextField.text = "No data"
    }
    
    @objc private func setNextInput(_ sender: AnyObject) {
//        guard let selectedRow = massPickerView?.selectedRow(inComponent: 1) else
//        { return }
//
//        let value = DailyTableViewCell.massValues[selectedRow]
//
//        cellDelegate?.didEndEditing(cell: self, item: .mass, value: value)
        didEndEditing(sender)
    }
    
    @objc private func didCancelEditing(_ sender: AnyObject) {
        resignFirstResponder()
        endEditing(true)
        print("canceled")
    }
    
    @objc private func didEndEditing(_ sender: AnyObject) {
        resignFirstResponder()
        endEditing(true)
        print("ended")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        massPickerView = UIPickerView()
//        massPickerToolbar = UIToolbar()
//
//        energyPickerView = UIPickerView()
//        energyPickerToolbar = UIToolbar()
    }
    
    // TODO: - make units user selectable
    
    public var mass: Measurement<UnitMass>? {
        didSet {
            if let mass = mass {
                massTextField.text = DailyTableViewCell.measurementFormatter.string(from: mass)
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
}

extension DailyTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == massPickerView {
            return component == 0 ? DailyTableViewCell.massMultipliers.count : DailyTableViewCell.massValues.count
        } else if pickerView == energyPickerView {
            return component == 0 ? DailyTableViewCell.energyMultipliers.count : DailyTableViewCell.energyValues.count
        }

        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == massPickerView {
            if component == 0 {
                return DailyTableViewCell.numberFormatter.string(from: DailyTableViewCell.massMultipliers[row] as NSNumber)
            }

            return DailyTableViewCell.numberFormatter.string(from: DailyTableViewCell.massValues[row] as NSNumber)
        } else if pickerView == energyPickerView {
            if component == 0 {
                return DailyTableViewCell.numberFormatter.string(from: DailyTableViewCell.energyMultipliers[row] as NSNumber)
            }

            return DailyTableViewCell.numberFormatter.string(from: DailyTableViewCell.energyValues[row] as NSNumber)
        }

        return "Pero kvržica" // wtf
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            if pickerView == massPickerView {
                DailyTableViewCell.massSelectedMultiplier = row
                massPickerView?.reloadComponent(1)
            } else if pickerView == energyPickerView {
                energyPickerView?.reloadComponent(1)
                DailyTableViewCell.energySelectedMultiplier = row
            }
        } else if component == 1 {
            if pickerView == massPickerView {
                mass = Measurement<UnitMass>(value: DailyTableViewCell.massValues[row], unit: .kilograms)
            } else if pickerView == energyPickerView {
                energy = Measurement<UnitEnergy>(value: Double(DailyTableViewCell.energyValues[row]), unit: .kilocalories)
            }
        }
    }
}


