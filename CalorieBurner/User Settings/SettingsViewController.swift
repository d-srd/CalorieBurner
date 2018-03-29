//
//  SettingsViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 27/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet private weak var healthKitUsageCell: UITableViewCell!
    
    @IBOutlet private weak var firstDayOfWeekCell: UITableViewCell!
    @IBOutlet private weak var firstDayOfWeekLabel: UILabel!
    
    @IBOutlet private weak var unitMassCell: UITableViewCell!
    @IBOutlet private weak var unitMassLabel: UILabel!
    
    @IBOutlet private weak var unitEnergyCell: UITableViewCell!
    @IBOutlet private weak var unitEnergyLabel: UILabel!
    
    @IBOutlet private weak var exportDataCell: UITableViewCell!
    @IBOutlet private weak var importDataCell: UITableViewCell!
    
    private var cancellationAction: UIAlertAction {
        return UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.deselectSelectedRow()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    private lazy var dayOfWeekSelectionViewController: UIAlertController! = {
        let controller = UIAlertController(title: "First day of week", message: nil, preferredStyle: .actionSheet)
        
        func handler(_ action: UIAlertAction) {
            firstDayOfWeek = daysOfWeek.index(of: action.title!)! + 1
            deselectSelectedRow()
        }
        
        for daySymbol in daysOfWeek {
            let action = UIAlertAction(title: daySymbol, style: .default, handler: handler)
            controller.addAction(action)
        }
        
        controller.addAction(cancellationAction)
        
        return controller
    }()
    
    private lazy var massUnitSelectionViewController: UIAlertController! = {
        let controller = UIAlertController(title: "Mass unit", message: nil, preferredStyle: .actionSheet)
        
        for unit in [UnitMass.kilograms, .pounds, .stones] {
            let action = UIAlertAction(title: measurementFormatter.string(from: unit).capitalized, style: .default) { _ in
                self.massUnit = unit
                self.deselectSelectedRow()
            }
            controller.addAction(action)
        }

        controller.addAction(cancellationAction)

        return controller
    }()

	private lazy var energyUnitSelectionViewController: UIAlertController! = {
		let controller = UIAlertController(title: "Energy unit", message: nil, preferredStyle: .actionSheet)

		for unit in [UnitEnergy.kilocalories, .kilojoules] {
            let action = UIAlertAction(title: measurementFormatter.string(from: unit).capitalized, style: .default) { _ in
                self.energyUnit = unit
                self.deselectSelectedRow()
            }
			controller.addAction(action)
		}

		controller.addAction(cancellationAction)

		return controller
	}()
    
    // map cells to functions they should perform when they are tapped
    // the async call is there because of a bug in iOS - sometimes when
    // a cell is tapped the delegate method "lags out" and presenting a
    // view controller takes up to 10 seconds
    private lazy var actionForCell: [UITableViewCell : () -> Void] = [
        firstDayOfWeekCell : { [weak self] in
            guard let wself = self else { return }
	        DispatchQueue.main.async {
		        wself.present(wself.dayOfWeekSelectionViewController, animated: true, completion: nil)
	        }
        },
        
        unitMassCell : { [weak self] in
            guard let wself = self else { return }
	        DispatchQueue.main.async {
		        wself.present(wself.massUnitSelectionViewController, animated: true, completion: nil)
	        }
        },
        
        unitEnergyCell : { [weak self] in
            guard let wself = self else { return }
	        DispatchQueue.main.async {
		        wself.present(wself.energyUnitSelectionViewController, animated: true, completion: nil)
	        }
        },
        
        exportDataCell: { [weak self] in
            guard let wself = self else { return }
            if let data = String(data: wself.csvManager.export(), encoding: .utf8) {
                print(data)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wself.deselectSelectedRow()
            }}
    ]
    
    private let daysOfWeek = Calendar.current.standaloneWeekdaySymbols
    private var firstDayOfWeek: Int {
        get {
            return UserDefaults.standard.firstDayOfWeek
        } set(day) {
            UserDefaults.standard.firstDayOfWeek = day
            firstDayOfWeekLabel.text = daysOfWeek[day - 1]
        }
    }
    
    private var massUnit: UnitMass {
        get {
            return UserDefaults.standard.mass ?? .kilograms
        } set(unit) {
            UserDefaults.standard.mass = unit
            unitMassLabel.text = measurementFormatter.string(from: unit).capitalized
        }
    }
    
    private var energyUnit: UnitEnergy {
        get {
            return UserDefaults.standard.energy ?? .kilocalories
        }
        set(unit) {
            UserDefaults.standard.energy = unit
            unitEnergyLabel.text = measurementFormatter.string(from: unit).capitalized
        }
    }
    
    private let measurementFormatter: MeasurementFormatter = {
        let fmt = MeasurementFormatter()
        fmt.unitStyle = .long
        fmt.unitOptions = .providedUnit
        return fmt
    }()
    private let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()
    private lazy var csvManager = DailyCSV(measurementFormatter: measurementFormatter, items: [])
    
    private func deselectSelectedRow() {
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstDayOfWeekLabel.text = daysOfWeek[firstDayOfWeek - 1]
        unitMassLabel.text = measurementFormatter.string(from: massUnit).capitalized
        unitEnergyLabel.text = measurementFormatter.string(from: energyUnit).capitalized

        do {
            csvManager.addItems(try CoreDataStack.shared.fetchAll())
        } catch {
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            actionForCell[cell]?()
        }
    }
    
    // disable selection of health kit cell
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if healthKitUsageCell == tableView.cellForRow(at: indexPath) {
            return nil
        }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell == healthKitUsageCell {
            cell.selectionStyle = .none
        }
    }

}
