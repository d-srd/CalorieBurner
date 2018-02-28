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
        fmt.dateFormat = "YYYY-MM-dd"
        
        return fmt
    }()
    
    private let prettyDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .long
        
        return fmt
    }()
    
    private let startingDate = Calendar.current.date(from: DateComponents(year: 2000, month: 01, day: 01))!
    private let endingDate = Calendar.current.date(from: DateComponents(year: 2030, month: 12, day: 31))!
    
    private lazy var dayCount = Calendar.current.dateComponents([.day], from: startingDate, to: endingDate).day!
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Used to calculate indexPaths in a UICollectionView
    private func indexPath(from date: Date) -> IndexPath? {
        guard date >= startingDate && date <= endingDate else {
            return nil
        }

        // a year component is just that, a year component
        // e.g. '2018-02-10' has a year component '2018'
        // sections start at the startingDate's year component
        // e.g. if '1970-01-01' is the startingDate, then
        // IndexPath(row: 0, section: 0) corresponds to that date
        // the day component is the number of days passed since
        // that particular date. in the case of the first example
        // it would be '31+10', or '41'
        let dayComponent = Calendar.current.dateComponents([.day], from: startingDate, to: date).day!

        return IndexPath(row: 0, section: dayComponent)
    }
    
    private func section(from newDate: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: startingDate, to: newDate).day!
    }
    
    private func date(from section: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: section), to: startingDate)!
    }
    
    // inverse of indexPath(from:)
    private func date(from indexPath: IndexPath) -> Date? {
        guard indexPath.section <= numberOfSections(in: tableView) && indexPath.row <= tableView(tableView, numberOfRowsInSection: indexPath.section) else {
            return nil
        }

        let componentsToBeAdded = DateComponents(day: indexPath.section)
        return Calendar.current.date(byAdding: componentsToBeAdded, to: startingDate)
    }
    
    private func scrollToItem(at date: Date, animated: Bool) {
        let indexPath = IndexPath(item: 0, section: section(from: date))

        tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 100
        tableView.sectionHeaderHeight = 44
        scrollToItem(at: Date(), animated: false)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dayCount
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
        
        if let date = date(from: indexPath),
           let dailies = try? viewContext.fetch(Daily.fetchRequest(in: date)),
           let daily = dailies.first
        {
            cell.mass = daily.mass
            cell.energy = daily.energy
        } else {
            cell.setEmpty()
        }
        
//        let massPicker = UIPickerView()
//        let massT = UIToolbar()

        cell.massPickerView = UIPickerView()
        cell.energyPickerView = UIPickerView()
        cell.massPickerToolbar = UIToolbar()
        cell.energyPickerToolbar = UIToolbar()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "kita"
        
        let date = Calendar.current.date(byAdding: .day, value: section, to: startingDate)!
        
        return prettyDateFormatter.string(from: date)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected date: ", longDateFormatter.string(from: date(from: indexPath.section)))
    }
}

