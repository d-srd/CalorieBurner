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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HealthStoreHelper.shared.requestAuthorization { (success, error) in
            print("success: \(success)\nerror: \(error)")
        }
    }
    
    @IBAction func saveDataToHealthKit(_ sender: Any) {
        guard let massValue = massTextField.text.flatMap(Double.init) else { return }
        
        let mass = HKQuantitySample(
            type: HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            quantity: HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: massValue),
            start: Date().addingTimeInterval(-5), end: Date()
        )
        
        HealthStoreHelper.shared.writeData(mass: mass) { (success, error) in
            guard error == nil else { print("error saving: \(error)"); return }
            print("successfully saved mass")
        }
    }
}
