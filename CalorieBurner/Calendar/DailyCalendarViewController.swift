//
//  File.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 18/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DailyCalendarViewCell: DayViewCell {
    @IBOutlet weak var existingItemView: UIView!
}

class DailyCalendarViewController: MonthlyCalendarViewController, DailyCollectionViewScrollDelegate {
    @IBOutlet weak var containerView: UIView!
    var dailyCollectionViewController: DailyCollectionViewController!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dailyCollection = segue.destination as? DailyCollectionViewController {
            dailyCollectionViewController = dailyCollection
            dailyCollectionViewController.view.autoresizingMask = []
            dailyCollectionViewController.view.frame = containerView.bounds
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        

        dailyCollectionViewController.dailyView.itemSize =
            CGSize(width: containerView.frame.width * 0.8, height: 250)
        dailyCollectionViewController.dailyView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UICollectionView needs an initial size to lay out the cells. this code is ignored, the one in didLayoutSubviews is used.
        dailyCollectionViewController.dailyView.itemSize =
            CGSize(width: containerView.frame.width * 0.8, height: 250)
//        dailyCollectionViewController.dailyView.shouldIgnoreScrollingAdjustment = true
//        calendarView.shouldIgnoreScrollingAdjustment = true
        dailyCollectionViewController.dailyView.dailyScrollDelegate = self
        dailyCollectionViewController.scrollToItem(at: self.today, animated: false)
        calendarView.selectDates([today])
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(unitsDidChange(_:)),
            name: NSNotification.Name.UnitMassChanged,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(unitsDidChange(_:)),
            name: NSNotification.Name.UnitEnergyChanged,
            object: nil
        )
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UnitMassChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UnitEnergyChanged, object: nil)
    }
    
    @objc private func unitsDidChange(_ notification: Notification) {
        dailyCollectionViewController.dailyView.reloadData()
    }
    
    func map(_ cell: DayViewCell?) -> DailyCalendarViewCell? {
        return cell as? DailyCalendarViewCell
    }
    
    override func configure(cell: DayViewCell?, cellState: CellState, animated: Bool) {
        super.configure(cell: cell, cellState: cellState, animated: animated)
        let cell = map(cell)
        
        if dailyCollectionViewController.doesItemExist(at: cellState.date) {
            cell?.existingItemView.isHidden = false

            if animated {
                UIView.animate(withDuration: animationSelectionDuration) {
                    cell?.existingItemView.alpha = 1
                }
            } else {
                cell?.existingItemView.alpha = 1
            }
        } else {
            if animated {
                UIView.animate(
                    withDuration: animationSelectionDuration,
                    animations: { cell?.existingItemView.alpha = 0 },
                    completion: { _ in cell?.existingItemView.isHidden = true }
                )
            } else {
                cell?.existingItemView.alpha = 0
                cell?.existingItemView.isHidden = true
            }
        }
    }
    
    override func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        super.calendar(calendar, didSelectDate: date, cell: cell, cellState: cellState)
        
        dailyCollectionViewController.scrollToItem(at: date, animated: true)
    }
    
    func dailyView(_ dailyView: DailyCollectionView, willScrollToItemAt date: Date) {
        if !calendarView.selectedDates.contains(date) {
            calendarView.scrollToDate(date)
            calendarView.deselectAllDates()
            calendarView.selectDates([date])
        }
    }
    
    func dailyView(_ dailyView: DailyCollectionView, didScrollToItemAt date: Date) {
        if !calendarView.selectedDates.contains(date) {
            calendarView.scrollToDate(date)
            calendarView.deselectAllDates()
            calendarView.selectDates([date])
        }
    }
}
