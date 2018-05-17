//
//  DailyCellDelegate.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 09/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

protocol DailyCellDelegate: class {
    func didEndEditing(cell: DailyDataCollectionViewCell, mass: Mass?)
    func didEndEditing(cell: DailyDataCollectionViewCell, energy: Energy?)
    func didEndEditing(cell: DailyDataCollectionViewCell, mood: Feelings?)
}
