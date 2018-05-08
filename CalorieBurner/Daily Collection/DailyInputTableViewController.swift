//
//  DailyInputTableViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 27/04/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

class DailyInputTableViewController: UITableViewController {
    @IBOutlet weak var massTextField: UITextField!
    @IBOutlet weak var energyTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    let massPickerView = DailyMassPickerView()
    let energyPickerView = DailyEnergyPickerView()
    
    var date: Date?
    private var mass: Mass? {
        didSet {
            massTextField.text = mass.flatMap(measurementFormatter.string)
        }
    }
    private var energy: Energy? {
        didSet {
            energyTextField.text = energy.flatMap(measurementFormatter.string)
        }
    }
    private var note: String? {
        return notesTextView.text
    }
    
    private let measurementFormatter: MeasurementFormatter = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        massPickerView.dailyDelegate = self
        energyPickerView.dailyDelegate = self
        massTextField.inputView = massPickerView
        energyTextField.inputView = energyPickerView
    }
    
    private func shouldSaveDaily() {
        guard let date = date else { return }
        try? CoreDataStack.shared.updateOrCreate(at: date, mass: mass, energy: energy, note: note)
    }
    
    @IBAction func doneButtonWasPressed(_ sender: Any) {
        shouldSaveDaily()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension DailyInputTableViewController: DailyItemPickerDelegate {
    func dailyPicker(_ picker: UIPickerView, valueDidChangeTo value: Double) {
        if picker == massPickerView {
            mass = Mass(value: value, unit: UserDefaults.standard.mass)
        } else if picker == energyPickerView {
            energy = Energy(value: value, unit: UserDefaults.standard.energy)
        }
    }
}
