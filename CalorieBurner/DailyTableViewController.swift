//
//  DailyTableViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 26/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import CoreData

class DailyTableViewController: UITableViewController {
    
    private let longDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        
        return fmt
    }()
    
    private lazy var fetchedResultsController: DailyFetchedResultsController = {
        let request = Daily.tableFetchRequest()
        let frc = DailyFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            dateBounds: (startingDate, endingDate)
        )
        
        return frc
    }()
    
    private let startingDate = Calendar.current.date(from: DateComponents(year: 2000, month: 01, day: 01))!
    private let endingDate = Calendar.current.date(from: DateComponents(year: 2030, month: 12, day: 31))!
    
    private lazy var dayCount = Calendar.current.dateComponents([.day], from: startingDate, to: endingDate).day!
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private func scrollToItem(at date: Date, animated: Bool) {
        guard let indexPath = fetchedResultsController.indexPath(for: date) else { return }

        tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? fetchedResultsController.performFetch()
        
        tableView.rowHeight = 151
        tableView.sectionHeaderHeight = 44
//        print(fetchedResultsController.indexPath(for: Date()))
        scrollToItem(at: Date(), animated: false)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(unitsChanged(_:)),
            name: .UnitMassChanged,
            object: nil
        )
    }
    
    @objc private func unitsChanged(_ sender: Any) {
        tableView.reloadData()
        scrollToItem(at: Date(), animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UnitMassChanged, object: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyCell", for: indexPath) as? DailyTableViewCell
        else { fatalError("nocell") }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? DailyTableViewCell else { return }
        
        if let object = fetchedResultsController.object(at: indexPath) {
            cell.mass = object.mass?.converted(to: UserDefaults.standard.mass ?? .kilograms)
            cell.energy = object.energy?.converted(to: UserDefaults.standard.energy ?? .kilocalories)
        } else {
            cell.setEmpty()
        }

        cell.massPickerView = DailyMassPickerView()
        cell.energyPickerView = DailyEnergyPickerView()
        cell.massPickerToolbar = DailyMassPickerToolbar()
        cell.energyPickerToolbar = DailyEnergyPickerToolbar()
        cell.cellDelegate = self
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return fetchedResultsController.titleForSection(section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
    
//    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Selected date: ", longDateFormatter.string(from: date(from: indexPath.section)))
//    }
}

extension DailyTableViewController: DailyCellDelegate {
    func didCancelEditing(cell: DailyTableViewCell, item: DailyItemType) {
        print("canceled, OH NO")
    }
    
    func didEndEditing(cell: DailyTableViewCell, with value: Measurement<UnitMass>) {
        guard let indexPath = tableView.indexPath(for: cell)
        else { print("error"); return }
        
        guard let date = fetchedResultsController.date(for: indexPath) else {
            print("error2"); return
        }

        
        do {
            let entry = try CoreDataStack.shared.updateOrCreate(at: date, mass: value, energy: nil)
        } catch {
            print((error as NSError).localizedDescription)
        }
    }
    
    func didEndEditing(cell: DailyTableViewCell, with value: Measurement<UnitEnergy>) {
        guard let indexPath = tableView.indexPath(for: cell),
            let date = fetchedResultsController.date(for: indexPath)
        else { print("error"); return }
        
        do {
            let entry = try CoreDataStack.shared.updateOrCreate(at: date, mass: nil, energy: value)
        } catch {
            print((error as NSError).localizedDescription)
        }
    }
    
    
}
