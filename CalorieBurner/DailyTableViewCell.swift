//
//  DailyTableViewCell.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 26/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

class DailyTableViewCell: UITableViewCell {
    
    private let measurementFormatter: MeasurementFormatter = {
        let fmt = MeasurementFormatter()
        fmt.unitOptions = .providedUnit
        fmt.unitStyle = .medium
        
        return fmt
    }()
    
    @IBOutlet weak private var massTextField: UITextField!
    @IBOutlet weak private var massUnitLabel: UILabel!
    @IBOutlet weak private var energyTextField: UITextField!
    @IBOutlet weak private var energyUnitLabel: UILabel!
    
    /// Makes the input views display "No data"
    public func setEmpty() {
        massTextField.text = "No data"
        energyTextField.text = "No data"
        massUnitLabel.text = nil
        energyUnitLabel.text = nil
    }
    
    // TODO: - make units modular, fix separating label and textfield
    // maybe make the textfield's first responder something that isn't a keyboard?
    // just make a stepper/picker that the user can choose their inputs with?
    
    public var mass: Measurement<UnitMass>? {
        get {
            guard let massStringValue = massTextField.text,
                  let massValue = Double(massStringValue)
            else { return nil }
            
            return Measurement<UnitMass>(value: massValue, unit: .kilograms)
        }
        set {
            if let mass = newValue {
                massTextField.text = String(mass.value)
                massUnitLabel.text = measurementFormatter.string(from: mass.unit)
            }
        }
    }
    
    public var energy: Measurement<UnitEnergy>? {
        get {
            guard let energyStringValue = energyTextField.text, let energyValue = Double(energyStringValue) else {
                return nil
            }
            
            return Measurement<UnitEnergy>(value: energyValue, unit: .kilocalories)
        } set {
            if let energy = newValue {
                energyTextField.text = String(energy.value)
                energyUnitLabel.text = measurementFormatter.string(from: energy.unit)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
