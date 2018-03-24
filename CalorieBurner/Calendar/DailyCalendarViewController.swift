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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillShow(_:)),
//            name: .UIKeyboardWillShow,
//            object: nil
//        )
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillHide(_:)),
//            name: .UIKeyboardWillHide,
//            object: nil
//        )
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
//    }
    
//    @objc private func keyboardWillShow(_ notification: Notification) {
//
////        self.view.frame.origin.y -= 300
//        // ugliest line of code I've written in this entire project
//        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
//            self.view.frame.origin.y == 0
//            else { return }
//
////        self.view.frame.origin.y -= (keyboardSize.height * 5)
//        bottomConstraint.constant = keyboardSize.height
//    }
//
//    @objc private func keyboardWillHide(_ notification: Notification) {
////        self.view.frame.origin.y += 300
//        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
//            self.view.frame.origin.y != 0
//            else { return }
//
////        self.view.frame.origin.y += (keyboardSize.height * 5)
//        bottomConstraint.constant = 20
//    }
    
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

