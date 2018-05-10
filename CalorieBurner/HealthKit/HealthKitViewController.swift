//
//  HealthKitViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 30/04/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import HealthKit

class HealthKitViewController: UIViewController {
    @IBOutlet weak var massTextField: UITextField!
    @IBOutlet weak var energyTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HealthStoreHelper.shared.requestAuthorization { (success, error) in
            print("success: \(success)\nerror: \(error)")
        }
    }
    
    @IBAction func saveMassToHealthKit(_ sender: Any) {
        guard let massValue = massTextField.text.flatMap(Double.init) else { return }
        
        let mass = HKQuantitySample(
            type: HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            quantity: HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: massValue),
            start: datePicker.date, end: datePicker.date
        )
        
        HealthStoreHelper.shared.writeData(sample: mass) { (success, error) in
            guard error == nil else { print("error saving: \(error)"); return }
            print("successfully saved mass")
        }
    }
    
    @IBAction func saveEnergyToHealthKit(_ sender: Any) {
        guard let energyValue = energyTextField.text.flatMap(Double.init) else { return }
        
        let energy = HKQuantitySample(type: HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
                                      quantity: HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: energyValue),
                                          start: datePicker.date, end: datePicker.date)
        
        HealthStoreHelper.shared.writeData(sample: energy) { (success, error) in
            guard error == nil else { print("error saving: \(error)"); return }
            print("successfully saved energy")
        }
    }
}
