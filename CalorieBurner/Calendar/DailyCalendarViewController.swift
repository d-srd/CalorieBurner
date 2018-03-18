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

class DailyCalendarViewController: MonthlyCalendarViewController, DailyCollectionViewDelegate {
    var dailyCollectionViewController: DailyCollectionViewController?
    
    override func configure(cell: DayViewCell?, cellState: CellState) {
        super.configure(cell: cell, cellState: cellState)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dailyCollection = segue.destination as? DailyCollectionViewController {
            dailyCollectionViewController = dailyCollection
            dailyCollectionViewController?.delegate = self
        }
    }
    
    func dailyView(_ dailyView: UICollectionView, didScrollToItemAt date: Date) {
        calendarView.scrollToDate(date)
        calendarView.deselectAllDates()
        calendarView.selectDates([date])
    }
    
    override func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        super.calendar(calendar, didSelectDate: date, cell: cell, cellState: cellState)
        
        dailyCollectionViewController?.scrollToItem(at: date, animated: true)
    }
}

