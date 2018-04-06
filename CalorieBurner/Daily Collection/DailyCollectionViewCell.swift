//
//  DailyTableViewCell.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 26/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import CocoaControls

@objc enum DailyItemType: Int {
    case mass
    case energy
}

protocol DailyCellDelegate: class {
    func willCancelEditing(cell: DailyCollectionViewCell, for itemType: DailyItemType)
    func didCancelEditing(cell: DailyCollectionViewCell, for itemType: DailyItemType)
    func didEndEditing(cell: DailyCollectionViewCell, mass: Measurement<UnitMass>)
    func didEndEditing(cell: DailyCollectionViewCell, energy: Measurement<UnitEnergy>)
    
}

protocol DailyViewModel {
    var massTextField: UITextField! { get set }
    var energyTextField: UITextField! { get set }
    
    var mass: Measurement<UnitMass>? { get set }
    var energy: Measurement<UnitEnergy>? { get set }
}

class DailyCollectionViewCell: UICollectionViewCell, DailyViewModel {
    @IBOutlet weak var massView: ShadowView!
    @IBOutlet weak var energyView: ShadowView!
    
    private static let measurementFormatter: MeasurementFormatter = {
        let fmt = MeasurementFormatter()
        fmt.unitOptions = .providedUnit
        fmt.unitStyle = .medium
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.roundingMode = .halfUp
        numberFormatter.isLenient = true
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.roundingIncrement = 0.25
        
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
        massTextField.text = "No data"
        energyTextField.text = "No data"
    }
    
    private func fillTextField<T: Unit>(with value: Measurement<T>?) {
        if T.self == UnitMass.self {
            massTextField.text = value.flatMap(DailyCollectionViewCell.measurementFormatter.string) ?? "No data"
        } else if T.self == UnitEnergy.self {
            energyTextField.text = value.flatMap(DailyCollectionViewCell.measurementFormatter.string) ?? "No data"
        }
    }
    
    // TODO: - make units user selectable
    
    public var mass: Measurement<UnitMass>? {
        didSet {
            fillTextField(with: mass)
        }
    }
    private var massBuffer: Measurement<UnitMass>? {
        didSet {
            fillTextField(with: massBuffer ?? mass)
        }
    }
    
    public var energy: Measurement<UnitEnergy>? {
        didSet {
            fillTextField(with: energy)
        }
    }
    private var energyBuffer: Measurement<UnitEnergy>? {
        didSet {
            fillTextField(with: energyBuffer ?? energy)
        }
    }
    
    @objc private func massTextFieldShouldBecomeFirstResponder(_ sender: Any) {
        massTextField.becomeFirstResponder()
    }
    
    @objc private func energyTextFieldShouldBecomeFirstResponder(_ sender: Any) {
        energyTextField.becomeFirstResponder()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let massGesture = UITapGestureRecognizer(target: self, action: #selector(massTextFieldShouldBecomeFirstResponder(_:)))
        massGesture.cancelsTouchesInView = false
        
        let energyGesture = UITapGestureRecognizer(target: self, action: #selector(energyTextFieldShouldBecomeFirstResponder(_:)))
        energyGesture.cancelsTouchesInView = false
        
        massView.addGestureRecognizer(massGesture)
        energyView.addGestureRecognizer(energyGesture)
    }
}

extension DailyCollectionViewCell: DailyItemPickerDelegate {
    func dailyPicker(_ picker: UIPickerView, valueDidChangeTo: Double) {
        if picker == massPickerView {
            massBuffer = Measurement<UnitMass>(value: valueDidChangeTo, unit: UserDefaults.standard.mass)
        } else {
            energyBuffer = Measurement<UnitEnergy>(value: valueDidChangeTo, unit: UserDefaults.standard.energy)
        }
        
        print(valueDidChangeTo)
    }
}

extension DailyCollectionViewCell: DailyToolbarDelegate {
    func didCancelEditing(_ type: DailyItemType) {
        cellDelegate?.willCancelEditing(cell: self, for: type)
        
        endEditing(true)
        
        switch type {
        case .mass:
            massBuffer = nil
        case .energy:
            energyBuffer = nil
        }
        
        cellDelegate?.didCancelEditing(cell: self, for: type)
    }
    
    func didEndEditing(_ type: DailyItemType) {
        endEditing(true)
        
        switch type {
        case .mass:
            mass = massBuffer
            cellDelegate?.didEndEditing(cell: self, mass: mass!)
            energyTextField.becomeFirstResponder()
        case .energy:
            energy = energyBuffer
            cellDelegate?.didEndEditing(cell: self, energy: energy!)
        }
    }
}
