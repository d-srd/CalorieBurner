//
//  ViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 25/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import CoreData

extension Notification.Name {
    static let UnitMassChanged = Notification.Name("unitMassChanged")
    static let UnitEnergyChanged = Notification.Name("unitEnergyChanged")
}

extension UserDefaults {
    
    var mass: UnitMass? {
        get {
            guard let encodedMassUnit = self.data(forKey: "massUnit") else { return nil }
            return NSKeyedUnarchiver.unarchiveObject(with: encodedMassUnit) as? UnitMass
        }
        set {
            guard let massUnit = newValue else { return }
            let encodedMassUnit = NSKeyedArchiver.archivedData(withRootObject: massUnit)
            self.set(encodedMassUnit, forKey: "massUnit")
        }
    }
    
    var energy: UnitEnergy? {
        get {
            guard let encodedEnergyUnit = self.data(forKey: "energyUnit") else {
                return nil
            }
            return NSKeyedUnarchiver.unarchiveObject(with: encodedEnergyUnit) as? UnitEnergy
        }
        set {
            guard let energyUnit = newValue else { return }
            let encodedEnergyUnit = NSKeyedArchiver.archivedData(withRootObject: energyUnit)
            self.set(encodedEnergyUnit, forKey: "energyUnit")
        }
    }
//    func get(_ item: DailyItemType) -> Unit {
//        switch item {
//        case .mass:
//            return self.data(forKey: "massUnit")
//        case .energy:
//            return self.data(forKey: "energyUnit")
//        }
//    }
}

class CRUDViewController: UIViewController {
    private enum DatabaseActionType { case add, delete, print }

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var massTextField: UITextField!
    @IBOutlet weak var energyTextField: UITextField!
    
    @IBAction func massUnitChanged(_ sender: UISegmentedControl) {
        let unit = massUnits[sender.selectedSegmentIndex]
//        let unitData = Data(bytes: , count: <#T##Int#>)
        
        UserDefaults.standard.mass = unit
        NotificationCenter.default.post(name: .UnitMassChanged, object: unit)
    }
    
    @IBAction func energyUnitChanged(_ sender: UISegmentedControl) {
        let unit = energyUnits[sender.selectedSegmentIndex]
        
        UserDefaults.standard.energy = unit
        NotificationCenter.default.post(name: .UnitEnergyChanged, object: unit)
    }
    
    private let massUnits = [UnitMass.kilograms, .pounds, .stones]
    private let energyUnits = [UnitEnergy.kilocalories, .kilojoules]
    
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
    
//    @objc func userDefaultsDidChange(_ notification: Notification) {
//        let mass = UserDefaults.standard.string(forKey: "massUnit")
//        let energy = UserDefaults.standard.string(forKey: "energyUnit")
//
//        let newMass = UnitMass(symbol: mass!)
//        let x = Unit(symbol: mass!)
//        let newEnergy = UnitEnergy(symbol: energy!)
//        let y = Unit(symbol: energy!)
//
//        print(measurementFormatter.string(from: newMass), measurementFormatter.string(from: newEnergy),
//              measurementFormatter.string(from: x), measurementFormatter.string(from: y)
//              )
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(userDefaultsDidChange(_:)),
//            name: UserDefaults.didChangeNotification,
//            object: nil
//        )
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
//    }
}
