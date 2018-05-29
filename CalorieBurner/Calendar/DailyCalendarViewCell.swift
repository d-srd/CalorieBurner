//
//  DailyCalendarViewCell.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 08/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

/// Calendar View Cell with an additional view to indicate the presence/lack of an existing item associated with that particular date.
class DailyCalendarViewCell: DayViewCell {
    @IBOutlet weak var existingItemView: UIView!
}
