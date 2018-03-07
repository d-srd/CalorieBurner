//
//  DailyTableViewCell.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 26/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

@objc enum DailyItemType: Int {
    case mass
    case energy
}

protocol DailyCellDelegate: class {
    func didCancelEditing(cell: DailyTableViewCell, item: DailyItemType)
    func didEndEditing(cell: DailyTableViewCell, with value: Measurement<UnitMass>)
    func didEndEditing(cell: DailyTableViewCell, with value: Measurement<UnitEnergy>)
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
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.roundingMode = .halfUp
        
        fmt.numberFormatter = numberFormatter

        return fmt
    }()

    weak var cellDelegate: DailyCellDelegate?
    
    // TODO: - clean this up
    
    weak var massPickerView: DailyMassPickerView? {
        didSet {
            guard let picker = massPickerView else { return }

            picker.dailyDelegate = self

            massTextField.inputView = picker
        }
    }

    weak var massPickerToolbar: DailyMassPickerToolbar? {
        didSet {
            guard let toolbar = massPickerToolbar else { return }

            toolbar.dailyDelegate = self
            
            massTextField.inputAccessoryView = toolbar
        }
    }

    weak var energyPickerView: DailyEnergyPickerView? {
        didSet {
            guard let picker = energyPickerView else { return }

            picker.dailyDelegate = self

            energyTextField.inputView = picker
        }
    }

    weak var energyPickerToolbar: DailyEnergyPickerToolbar? {
        didSet {
            guard let toolbar = energyPickerToolbar else { return }
            
            toolbar.dailyDelegate = self

            energyTextField.inputAccessoryView = toolbar
        }
    }
    
    @IBOutlet weak var massTextField: UITextField!
    @IBOutlet weak var energyTextField: UITextField!
    
    /// Makes the input views display "No data"
    public func setEmpty() {
        mass = nil
        energy = nil
    }
    
    // TODO: - make units user selectable
    
    public var mass: Measurement<UnitMass>? {
        didSet {
            if let mass = mass {
                massTextField.text = DailyTableViewCell.measurementFormatter.string(from: mass)
            } else {
                massTextField.placeholder = "No data"
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
                massTextField.placeholder = "No data"
            }
        }
    }
    
    public var energy: Measurement<UnitEnergy>? {
        didSet {
            if let energy = energy {
                energyTextField.text = DailyTableViewCell.measurementFormatter.string(from: energy)
            } else {
                energyTextField.placeholder = "No data"
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
                energyTextField.placeholder = "No data"
            }
        }
    }
}

extension DailyTableViewCell: DailyItemPickerDelegate {
    func dailyPicker(_ picker: UIPickerView, valueDidChangeTo: Double) {
        if picker == massPickerView {
            massBuffer = Measurement<UnitMass>(value: valueDidChangeTo, unit: UserDefaults.standard.mass ?? .kilograms)
        } else {
            energyBuffer = Measurement<UnitEnergy>(value: valueDidChangeTo, unit: UserDefaults.standard.energy ?? .kilocalories)
        }
        
        print(valueDidChangeTo)
    }
}

extension DailyTableViewCell: DailyToolbarDelegate {
    func didCancelEditing(_ type: DailyItemType) {
        endEditing(true)
        
        switch type {
        case .mass:
            massBuffer = nil
        case .energy:
            energyBuffer = nil
        }
        
        cellDelegate?.didCancelEditing(cell: self, item: type)
    }
    
    func didEndEditing(_ type: DailyItemType) {
        endEditing(true)
        
        switch type {
        case .mass:
            mass = massBuffer
            cellDelegate?.didEndEditing(cell: self, with: mass!)
            energyTextField.becomeFirstResponder()
        case .energy:
            energy = energyBuffer
            cellDelegate?.didEndEditing(cell: self, with: energy!)
        }
    }
}
