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
    
    private static let longDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "YYYY-MM-dd"
        
        return fmt
    }()
    
    private static let prettyDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .long
        
        return fmt
    }()
    
    private let startingDate: Date = {
        return longDateFormatter.date(from: "2000-01-01")!
    }()
    private let endingDate: Date = {
        return longDateFormatter.date(from: "2030-01-01")!
    }()
    
    private lazy var dayCount: Int = {
        return Calendar.current.dateComponents([.day], from: startingDate, to: endingDate).day!
    }()
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    /// Used to calculate indexPaths in a UICollectionView
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
//        let yearsComponent = Calendar.current.dateComponents([.year], from: startingDate, to: date).year!
        let dayComponent = Calendar.current.dateComponents([.day], from: startingDate, to: date).day!
        
        return IndexPath(row: 0, section: dayComponent)
    }
    
    /// inverse of indexPath(from:)
    private func date(from indexPath: IndexPath) -> Date? {
        guard indexPath.section <= numberOfSections(in: tableView) && indexPath.row <= tableView(tableView, numberOfRowsInSection: indexPath.section) else {
            return nil
        }
        
        let componentsToBeAdded = DateComponents(day: indexPath.section)
        return Calendar.current.date(byAdding: componentsToBeAdded, to: startingDate)
    }
    
    private func scrollToItem(at date: Date, animated: Bool) {
        guard let indexPath = indexPath(from: date) else { return }
        
        tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DailyCell", for: indexPath) as? DailyTableViewCell,
            let date = date(from: indexPath)
        else { return UITableViewCell() }
        
        if let dailies = try? viewContext.fetch(Daily.fetchRequest(in: date)),
           let daily = dailies.first
        {
            print(daily.mass, daily.energy)
            cell.mass = daily.mass
            cell.energy = daily.energy
        } else {
            cell.setEmpty()
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let date = date(from: IndexPath(row: 0, section: section)) else {
            return nil
        }
        
        return DailyTableViewController.prettyDateFormatter.string(from: date)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
