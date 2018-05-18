//
//  TodayViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 17/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    let startDate = Calendar.current.date(from: DateComponents(year: 2018, month: 01, day: 01))!
    let endDate = Date()
    let mediator = TDEEMediator(context: CoreDataStack.shared.viewContext)
    
    @IBAction func updateStuff(_ sender: Any) {
        print("update")
        print(mediator.averageMass(in: (startDate, endDate)))
        print(mediator.sumEnergy(in: (startDate, endDate)))
        print(try? CoreDataStack.shared.fetchAll().map { $0.mass })
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UnitMassChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UnitEnergyChanged, object: nil)
    }
    
    @objc private func unitsDidChange(_ sender: Any) {
        
    }
}
