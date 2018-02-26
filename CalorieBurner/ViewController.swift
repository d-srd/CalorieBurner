//
//  ViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 25/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    private enum DatabaseActionType { case add, delete, print }

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var massTextField: UITextField!
    @IBOutlet weak var energyTextField: UITextField!
    
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let measurementFormatter: MeasurementFormatter = {
        let fmt = MeasurementFormatter()
        fmt.unitOptions = .providedUnit
        fmt.unitStyle = .medium
        
        return fmt
    }()
    
    private func performAction(_ type: DatabaseActionType, context: NSManagedObjectContext) {
        switch type {
        case .add:
            if let massTextValue = massTextField.text,
               let massValue = Double(massTextValue),
               let energyTextValue = energyTextField.text,
               let energyValue = Double(energyTextValue)
            {
                let mass = Measurement(value: massValue, unit: UnitMass.kilograms)
                let energy = Measurement(value: energyValue, unit: UnitEnergy.kilocalories)
                
                print(mass)
                print(energy)
                
                if let dailies = try? context.fetch(Daily.fetchRequest(in: datePicker.date)) as [Daily],
                   let daily = dailies.first
                {
                    daily.mass = mass
                    daily.energy = energy
                    daily.created = datePicker.date
                    daily.isFromHealthKit = false
                } else {
                    let daily = Daily(context: context)
                    daily.mass = mass
                    daily.energy = energy
                    daily.created = datePicker.date
                    daily.isFromHealthKit = false
                }
                
                try? context.save()
            }
            
        case .delete:
            let requestDeletion = Daily.fetchRequest(in: datePicker.date)
            if let dailies = try? context.fetch(requestDeletion) as [Daily],
               let daily = dailies.first
            {
                context.delete(daily)
                try? context.save()
            }
            
        case .print:
            let request = Daily.fetchRequest(in: datePicker.date)
            if let dailies = try? context.fetch(request) as [Daily],
               let daily = dailies.first
            {
                guard let mass = daily.mass, let energy = daily.energy else {
                    return
                }
                print(Daily.dateFormatter.string(from: daily.created))
                print(measurementFormatter.string(from: mass))
                print(measurementFormatter.string(from: energy))
            } else {
                print("no data for ", Daily.dateFormatter.string(from: datePicker.date))
            }
        }
    }
    
    @IBAction func performDatabaseAction(_ sender: UIButton) {
        switch sender.currentTitle {
        case "Add"?:
            performAction(.add, context: viewContext)
        case "Delete"?:
            performAction(.delete, context: viewContext)
        case "Print"?:
            performAction(.print, context: viewContext)
        default:
            print("Unsupported action")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

