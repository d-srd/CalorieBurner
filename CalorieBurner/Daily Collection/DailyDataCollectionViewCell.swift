//
//  DailyTableViewCell.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 26/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class DailyCollectionViewCell: UICollectionViewCell { }

class DailyDataCollectionViewCell: DailyCollectionViewCell {
    @IBOutlet weak var dailyInputView: DailyInputView!
    
    func configure(mass: Mass?, energy: Energy?, mood: Feelings?) {
        dailyInputView.mass = mass
        dailyInputView.energy = energy
        dailyInputView.mood = mood
    }
}
