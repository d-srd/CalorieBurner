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

fileprivate let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.roundingMode = .halfUp
    numberFormatter.isLenient = true
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.roundingIncrement = 0.1
    numberFormatter.allowsFloats = true
    numberFormatter.locale = Locale.current
    
    return numberFormatter
}()

fileprivate let measurementFormatter: MeasurementFormatter = {
    let fmt = MeasurementFormatter()
    fmt.unitOptions = .providedUnit
    fmt.unitStyle = .medium
    fmt.numberFormatter = numberFormatter
    fmt.locale = Locale.current
    
    return fmt
}()

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
    
    // this is set by the massPickerView's delegate, i.e. the cell
    public var mass: Measurement<UnitMass>? {
        didSet { massTextField.text = mass.flatMap(measurementFormatter.string) }
    }
    
    // useful for cancelling the editing action
    private var massBuffer: Measurement<UnitMass>?
    
    // this is set by the energyPickerView's delegate, i.e. this class
    public var energy: Measurement<UnitEnergy>? {
        didSet { energyTextField.text = energy.flatMap(measurementFormatter.string) }
    }
    
    private var energyBuffer: Measurement<UnitEnergy>?
    
    public var note: String? {
        didSet {
            notesTextView.text = note
        }
    }
    
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
        
        // look at me. i am the delegate now
        massTextField.delegate = self
        energyTextField.delegate = self
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

extension DailyDataCollectionViewCell: UITextFieldDelegate {
    func isConvertibleToDecimal(_ string: String) -> Bool {
        return numberFormatter.number(from: string) != nil
    }
    
    // save the measurements in the buffer, as the textfield's text will clear when it is tapped. if the user cancels editing a textfield (i.e. taps outside of the textfield, or doesnt tap the done button), we can restore it
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == massTextField && mass != nil {
            massBuffer = mass
        } else if textField == energyTextField && energy != nil {
            energyBuffer = energy
        }
        
        return true
    }
    
    // make sure that the input is a decimal number
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.isEmpty else { return true }
        
        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return isConvertibleToDecimal(replacementText)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == massTextField {
           if let newMeasurementValueString = textField.text, let newMeasurementValue = Double(newMeasurementValueString) {
            massBuffer?.value = newMeasurementValue
           }
            mass = massBuffer
        } else if textField == energyTextField {
            if let newMeasurementValueString = textField.text, let newMeasurementValue = Double(newMeasurementValueString) {
                energyBuffer?.value = newMeasurementValue
            }
            energy = energyBuffer
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == massTextField {
            cellDelegate?.didEndEditing(cell: self, mass: mass)
        } else if textField == energyTextField {
            cellDelegate?.didEndEditing(cell: self, energy: energy)
        }
    }
}
