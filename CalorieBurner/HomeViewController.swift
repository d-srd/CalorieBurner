//
//  TodayViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 17/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

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
    fmt.numberFormatter = numberFormatter
    return fmt
}()


class HomeViewController: UIViewController {
    @IBOutlet weak var tdeeLabel: UILabel!
    
    @IBOutlet weak var deltaMassLabel: UILabel!
    @IBOutlet weak var deltaEnergyLabel: UILabel!
    
    @IBOutlet weak var startingMassLabel: UILabel!
    @IBOutlet weak var goalMassLabel: UILabel!
    @IBOutlet weak var currentMassLabel: UILabel!
    @IBOutlet weak var massProgressPercentageLabel: UILabel!
    
    @IBOutlet weak var currentMassLabelLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var massProgressView: UIProgressView!
    
    let startDate = Calendar.current.date(from: DateComponents(year: 2018, month: 01, day: 01))!
    let endDate = Date()
    
    lazy var mediator = TDEEMediator(context: CoreDataStack.shared.viewContext, startDate: startDate, endDate: endDate)
    let brain = CalorieBrain()
    
    private var energyUnit: UnitEnergy = UserDefaults.standard.energy
    private var massUnit: UnitMass = UserDefaults.standard.mass
    
    private var startingMass: Mass? {
        didSet {
            startingMassLabel.text = startingMass.map(measurementFormatter.string)
            setNeedsMassProgressRecalibration()
        }
    }
    
    private var goalMass: Mass? {
        didSet {
            goalMassLabel.text = goalMass.map(measurementFormatter.string)
            setNeedsMassProgressRecalibration()
        }
    }
    
    private var currentMass: Mass? {
        let latest = try? CoreDataStack.shared.fetchLatest()
        return latest??.mass
    }
    
    lazy var massGoalAlertController: UIAlertController = {
        let ac = UIAlertController(title: "Set goals", message: nil, preferredStyle: .alert)
        
        ac.addTextField() {
            $0.keyboardType = .decimalPad
            $0.keyboardAppearance = .dark
            $0.placeholder = "Starting weight"
            $0.delegate = self
        }
        ac.addTextField() {
            $0.keyboardType = .decimalPad
            $0.keyboardAppearance = .dark
            $0.placeholder = "Goal weight"
            $0.delegate = self
        }
        
        let doneAction = UIAlertAction(title: "Done", style: .default) { [unowned self, ac] _ in
            if let startingMassValue = ac.textFields?.first?.text.flatMap(Double.init) {
                self.startingMass = Mass(value: startingMassValue, unit: self.massUnit)
            }
            
            if let goalMassValue = ac.textFields?.last?.text.flatMap(Double.init) {
                self.goalMass = Mass(value: goalMassValue, unit: self.massUnit)
            }
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(doneAction)
        
        return ac
    }()
    
    private var weeklyEntries: [Week] {
        return mediator.transformDailies()
    }
    
    private var tdee: Energy? {
        let value = brain.calculateTDEE(using: weeklyEntries)
        return value.map { Energy(value: $0, unit: .kilocalories).converted(to: energyUnit) }
    }
    
    private var deltaMass: Mass? {
        let value = brain.calculateDelta(.mass, from: weeklyEntries)
        return value.map { Mass(value: $0, unit: .kilograms).converted(to: massUnit) }
    }
    
    private var deltaEnergy: Energy? {
        let value = brain.calculateDelta(.energy, from: weeklyEntries)
        return value.map { Energy(value: $0, unit: .kilocalories).converted(to: energyUnit) }
    }
    
    private var progressPosition: CGPoint {
        let horizontal = massProgressView.bounds.width * CGFloat(massProgressView.progress)
        return view.convert(CGPoint(x: horizontal, y: 0), from: massProgressView)
    }
    
    private func setNeedsMassProgressRecalibration() {
        guard let start = startingMass, let goal = goalMass, let current = currentMass
        else { return }
        
        let startToGoalDelta = abs(start.value - goal.value)
        let completed = abs(start.value - current.value)
        
        let progress = completed / startToGoalDelta
        
        var progressPoint = view.convert(CGPoint(x: CGFloat(progress) * massProgressView.bounds.width, y: 0),
                                         from: massProgressView)
        
        // this progress view is contained in a shadow view. the progress view's frame origin is 0.
        // to get the actual distance from the left edge of the screen to the progress view, we need
        // to look at its superview, i.e. a shadow view
        
        progressPoint.x -= massProgressView.superview!.frame.minX
        
        if progressPoint.x > massProgressView.superview!.frame.minX &&
           progressPoint.x < (massProgressView.superview!.frame.maxX + currentMassLabel.bounds.width)
        {
            progressPoint.x -= currentMassLabel.bounds.width / 2
        }
        
        massProgressView.progress = Float(progress)
        
        // code smell
        numberFormatter.numberStyle = .percent
        massProgressPercentageLabel.text = numberFormatter.string(from: NSNumber(value: progress)).map { $0 + " of the way to your goal weight" }
        numberFormatter.numberStyle = .decimal
        
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.currentMassLabel.text = measurementFormatter.string(from: current)
            self?.currentMassLabelLeadingConstraint.constant = progressPoint.x
            self?.view.layoutIfNeeded()
        }
    }
    
    private func updateTDEELabel() {
        tdeeLabel.text = tdee.map(measurementFormatter.string)
    }
    
    private func updateDeltaLabel<T>(_ label: UILabel, measurement: Measurement<T>?) {
        guard let measurement = measurement else { return }
        
        switch measurement.value {
        case ..<0:
            label.textColor = UIColor.green
        case 0:
            label.textColor = UIColor.cyan
        case 0...:
            label.textColor = UIColor.red
        default: fatalError("wtf")
        }
        
        label.text = measurementFormatter.string(from: measurement)
    }
    
    @objc private func unitsDidChange(_ sender: Any) {
        energyUnit = UserDefaults.standard.energy
        massUnit = UserDefaults.standard.mass
        
        updateTDEELabel()
        updateDeltaLabel(deltaMassLabel, measurement: deltaMass)
        updateDeltaLabel(deltaEnergyLabel, measurement: deltaEnergy)
    }
    
    @objc private func showMassAlert(_ sender: Any) {
        present(massGoalAlertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTDEELabel()
        updateDeltaLabel(deltaMassLabel, measurement: deltaMass)
        updateDeltaLabel(deltaEnergyLabel, measurement: deltaEnergy)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(unitsDidChange(_:)),
                                               name: .UnitMassChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(unitsDidChange(_:)),
                                               name: .UnitEnergyChanged,
                                               object: nil)
        
        massProgressView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMassAlert(_:)))
        
        massProgressView.addGestureRecognizer(tap)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UnitMassChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UnitEnergyChanged, object: nil)
    }
}

extension HomeViewController: UITextFieldDelegate {
    private func isConvertibleToDecimal(_ string: String) -> Bool {
        return numberFormatter.number(from: string) != nil
    }
    
    private func isBelowMaxLength(_ string: String) -> Bool {
        return string.count < 10
    }
    
    // make sure that the input is a decimal number
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.isEmpty else { return true }
        
        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return isConvertibleToDecimal(replacementText) && isBelowMaxLength(replacementText)
    }
}
