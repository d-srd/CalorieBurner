//
//  DailyTableViewCell.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 26/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

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
    @IBOutlet weak var moodView: ShadowView!
    
    @IBOutlet weak var massTextField: UITextField!
    @IBOutlet weak var energyTextField: UITextField!
    
    weak var cellDelegate: DailyCellDelegate?
    
    public var mass: Measurement<UnitMass>? {
        didSet { massTextField.text = mass.flatMap(measurementFormatter.string) }
    }
    
    // useful for cancelling the editing action
    // example usage:
    // 0. a cell with mass text field containing "50 kg" is displayed
    // 1. user taps text field
    // 2. mass is copied to massbuffer
    // 3. text field is cleared along with the mass
    // 4. user enters some numbers and deletes them, leaving an empty text field
    // 5. text field is about to resign first responder
    // 6. mass is copied from massbuffer
    // 7. initial text in text field is restored
    private var massBuffer: Measurement<UnitMass>?
    
    public var energy: Measurement<UnitEnergy>? {
        didSet { energyTextField.text = energy.flatMap(measurementFormatter.string) }
    }
    
    private var energyBuffer: Measurement<UnitEnergy>?
    
    public var note: String? {
        didSet {  }
    }
    
    // add some convenient tap gestures so the user does not have to press the actual textfield to initiate editing
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let massGesture = UITapGestureRecognizer(target: self, action: #selector(massTextFieldShouldBecomeFirstResponder(_:)))
        massGesture.cancelsTouchesInView = false
        
        let energyGesture = UITapGestureRecognizer(target: self, action: #selector(energyTextFieldShouldBecomeFirstResponder(_:)))
        energyGesture.cancelsTouchesInView = false
        
//        let notesGesture = UITapGestureRecognizer(target: self, action: #selector(notesTextViewShouldBecomeFirstResponder(_:)))
//        notesGesture.cancelsTouchesInView = false
        
        massView.addGestureRecognizer(massGesture)
        energyView.addGestureRecognizer(energyGesture)
//        moodView.addGestureRecognizer(notesGesture)
        
        // look at me. i am the delegate now
        massTextField.delegate = self
        energyTextField.delegate = self
//        notesTextView.delegate = self
        
        massTextField.keyboardDistanceFromTextField = 10
        energyTextField.keyboardDistanceFromTextField = 10
    }
    
    @objc private func massTextFieldShouldBecomeFirstResponder(_ sender: Any) {
        massTextField.becomeFirstResponder()
    }
    
    @objc private func energyTextFieldShouldBecomeFirstResponder(_ sender: Any) {
        energyTextField.becomeFirstResponder()
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
