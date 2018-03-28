//
//  SettingsViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 27/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var firstDayOfWeekCell: UITableViewCell!
    @IBOutlet weak var firstDayOfWeekLabel: UILabel!
    
    @IBOutlet weak var unitMassCell: UITableViewCell!
    @IBOutlet weak var unitMassLabel: UILabel!
    
    @IBOutlet weak var unitEnergyCell: UITableViewCell!
    @IBOutlet weak var unitEnergyLabel: UILabel!
    
    private var dayOfWeekSelectionViewController: UIAlertController!
    private var massUnitSelectionViewController: UIAlertController!
    private var energyUnitSelectionViewController: UIAlertController!
    
    private let measurementFormatter = MeasurementFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dayOfWeekSelectionViewController = {
            let controller = UIAlertController(title: "First day of week", message: nil, preferredStyle: .actionSheet)
            
            func handler(_ action: UIAlertAction) {
                print(action)
                firstDayOfWeekLabel.text = action.title
            }
            
            for daySymbol in ["Saturday", "Sunday", "Monday"] {
                let action = UIAlertAction(title: daySymbol, style: .default, handler: handler)
                controller.addAction(action)
            }
            
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in self.dismiss(animated: true, completion: nil) }))
            
            return controller
        }()
        
        massUnitSelectionViewController = {
            let controller = UIAlertController(title: "Mass unit", message: nil, preferredStyle: .actionSheet)
            
            func handler(_ action: UIAlertAction) {
                print(action)
                unitMassLabel.text = action.title
            }
            
            for massUnitSymbol in [UnitMass.kilograms, .pounds, .stones].map(measurementFormatter.string) {
                let action = UIAlertAction(title: massUnitSymbol, style: .default, handler: handler)
                controller.addAction(action)
            }
            
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in self.dismiss(animated: true, completion: nil) }))
            
            return controller
        }()
        
        energyUnitSelectionViewController = {
            let controller = UIAlertController(title: "Energy unit", message: nil, preferredStyle: .actionSheet)
            
            func handler(_ action: UIAlertAction) {
                print(action)
                unitEnergyLabel.text = action.title
            }
            
            for energyUnitSymbol in [UnitEnergy.kilocalories, .kilojoules].map(measurementFormatter.string) {
                let action = UIAlertAction(title: energyUnitSymbol, style: .default, handler: handler)
                controller.addAction(action)
            }
            
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in self.dismiss(animated: true, completion: nil) }))
            
            return controller
        }()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath == tableView.indexPath(for: firstDayOfWeekCell) {
            present(dayOfWeekSelectionViewController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == tableView.indexPath(for: firstDayOfWeekCell) {
            present(dayOfWeekSelectionViewController, animated: true, completion: nil)
        } else if indexPath == tableView.indexPath(for: unitMassCell) {
            present(massUnitSelectionViewController, animated: true, completion: nil)
        } else if indexPath == tableView.indexPath(for: unitEnergyCell) {
            present(energyUnitSelectionViewController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
