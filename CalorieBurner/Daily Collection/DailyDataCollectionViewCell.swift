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
    func willBeginEditing(cell: DailyDataCollectionViewCell, with inputView: UIView)
//    func willCancelEditing(cell: DailyCollectionViewCell, for itemType: MeasurementItems)
//    func didCancelEditing(cell: DailyCollectionViewCell, for itemType: MeasurementItems)
    func didEndEditing(cell: DailyDataCollectionViewCell, mass: Mass?)
    func didEndEditing(cell: DailyDataCollectionViewCell, energy: Energy?)
}

class DailyCollectionViewCell: UICollectionViewCell { }

class EmptyDailyCollectionViewCell: DailyCollectionViewCell { }

class DailyDataCollectionViewCell: DailyCollectionViewCell {
    // container view for mass input textfield
    @IBOutlet weak var massView: ShadowView!
    
    // container view for energy input textfield
    @IBOutlet weak var energyView: ShadowView!
    
    // container view for note input textfield
    @IBOutlet weak var notesView: ShadowView!
    
    @IBOutlet weak var massTextField: UITextField!
    @IBOutlet weak var energyTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    weak var cellDelegate: DailyCellDelegate?
    
    // preconfigured UIPickerView with sensible values for picking a mass
    // the delegate just notifies us of value changes
    var massPickerView: DailyMassPickerView? {
        didSet {
            guard let picker = massPickerView else { return }
            
            picker.dailyDelegate = self
            
            massTextField.inputView = picker
        }
    }
    
    // preconfigured UIPickerView with sensible values for picking an energy
    var energyPickerView: DailyEnergyPickerView? {
        didSet {
            guard let picker = energyPickerView else { return }
            
            picker.dailyDelegate = self
            
            energyTextField.inputView = picker
        }
    }
    
    // this is set by the massPickerView's delegate, i.e. the cell
    public var mass: Measurement<UnitMass>? {
        didSet {
            fillTextField(with: mass)
        }
    }
    
    // useful for cancelling the editing action
    private var massBuffer: Measurement<UnitMass>? {
        didSet {
            fillTextField(with: massBuffer ?? mass)
        }
    }
    
    // this is set by the energyPickerView's delegate, i.e. this class
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
    
    public var note: String? {
        didSet {
            notesTextView.text = note
        }
    }

    // we gotta print out those measurements somehow
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
    
    // add some convenient tap gestures so the user does not have to press the actual textfield to initiate editing
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
    
    /// Makes the input views display "No data"
    public func setEmpty() {
        massTextField.text = "Missing data"
        energyTextField.text = "Missing data"
    }
    
    // convenience
    private func fillTextField<T: Unit>(with value: Measurement<T>?) {
        if T.self == UnitMass.self {
            massTextField.text = value.flatMap(DailyDataCollectionViewCell.measurementFormatter.string) ?? "Missing data"
        } else if T.self == UnitEnergy.self {
            energyTextField.text = value.flatMap(DailyDataCollectionViewCell.measurementFormatter.string) ?? "Missing data"
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
}

extension DailyDataCollectionViewCell: DailyItemPickerDelegate {
    func dailyPicker(_ picker: UIPickerView, valueDidChangeTo: Double) {
        if picker == massPickerView {
            massBuffer = Measurement<UnitMass>(value: valueDidChangeTo, unit: UserDefaults.standard.mass)
        } else {
            energyBuffer = Measurement<UnitEnergy>(value: valueDidChangeTo, unit: UserDefaults.standard.energy)
        }
    }
}
