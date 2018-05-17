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
    lazy var mediator = TDEEMediator(startDate: startDate,
                                     endDate: endDate,
                                     context: CoreDataStack.shared.viewContext)
    
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
