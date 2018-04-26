//
//  DailyTableViewCell.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 26/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import CocoaControls
import IQKeyboardManager

protocol DailyCellDelegate: class {
    func willBeginEditing(cell: DailyCollectionViewCell, with inputView: UIView)
//    func willCancelEditing(cell: DailyCollectionViewCell, for itemType: MeasurementItems)
//    func didCancelEditing(cell: DailyCollectionViewCell, for itemType: MeasurementItems)
    func didEndEditing(cell: DailyCollectionViewCell, mass: Mass?)
    func didEndEditing(cell: DailyCollectionViewCell, energy: Energy?)
    func didPressArrowButton(cell: DailyCollectionViewCell, in direction: DailyToolbarArrowDirection)
}

class DailyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var massView: ShadowView!
    @IBOutlet weak var energyView: ShadowView!
    @IBOutlet weak var notesView: ShadowView!
    
    private static let measurementFormatter: MeasurementFormatter = {
        let fmt = MeasurementFormatter()
        fmt.unitOptions = .providedUnit
        fmt.unitStyle = .medium
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.roundingMode = .halfUp
        numberFormatter.isLenient = true
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.roundingIncrement = 0.25
        
        fmt.numberFormatter = numberFormatter

        return fmt
    }()

    weak var cellDelegate: DailyCellDelegate?
    
    // TODO: - clean this up
    
    var massPickerView: DailyMassPickerView? {
        didSet {
            guard let picker = massPickerView else { return }

            picker.dailyDelegate = self

            massTextField.inputView = picker
        }
    }
    
    var energyPickerView: DailyEnergyPickerView? {
        didSet {
            guard let picker = energyPickerView else { return }

            picker.dailyDelegate = self

            energyTextField.inputView = picker
        }
    }

    @IBOutlet weak var massTextField: UITextField!
    @IBOutlet weak var energyTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
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
    
    @objc private func notesTextViewShouldBecomeFirstResponder(_ sender: Any) {
        notesTextView.becomeFirstResponder()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let massGesture = UITapGestureRecognizer(target: self, action: #selector(massTextFieldShouldBecomeFirstResponder(_:)))
        massGesture.cancelsTouchesInView = false
        
        let energyGesture = UITapGestureRecognizer(target: self, action: #selector(energyTextFieldShouldBecomeFirstResponder(_:)))
        energyGesture.cancelsTouchesInView = false
        
        let notesGesture = UITapGestureRecognizer(target: self, action: #selector(notesTextViewShouldBecomeFirstResponder(_:)))
        notesGesture.cancelsTouchesInView = false
        
        massView.addGestureRecognizer(massGesture)
        energyView.addGestureRecognizer(energyGesture)
        notesView.addGestureRecognizer(notesGesture)
        
        massPickerView = DailyMassPickerView()
        energyPickerView = DailyEnergyPickerView()
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
