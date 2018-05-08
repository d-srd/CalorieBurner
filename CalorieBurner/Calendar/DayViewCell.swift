//
//  DayViewCell.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 14/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import JTAppleCalendar

/// Used solely for displaying the particular day's index and whether or not it's selected
class DayViewCell: JTAppleCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectionView: UIView!
}
