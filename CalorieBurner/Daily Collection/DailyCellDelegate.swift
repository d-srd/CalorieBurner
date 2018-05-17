//
//  DailyCellDelegate.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 09/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

protocol DailyInputViewDelegate: class {
    func didEndEditing(_ view: DailyInputView, mass: Mass?)
    func didEndEditing(_ view: DailyInputView, energy: Energy?)
    func didEndEditing(_ view: DailyInputView, mood: Feelings?)
}
