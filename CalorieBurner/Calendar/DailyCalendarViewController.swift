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
    @IBOutlet weak var containerView: UIView!
    var dailyCollectionViewController: DailyCollectionViewController!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dailyCollection = segue.destination as? DailyCollectionViewController {
            dailyCollectionViewController = dailyCollection
            dailyCollectionViewController.delegate = self
//            dailyCollectionViewController.cellWidth = containerView.frame.width * 0.8
//            dailyCollectionViewController.cellHeight = containerView.frame.height * 0.8
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dailyCollectionViewController.cellWidth = containerView.frame.width * 0.6
        dailyCollectionViewController.cellHeight = containerView.frame.height * 0.9
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: .UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: .UIKeyboardWillHide,
            object: nil
        )
        
//        dailyCollectionViewController
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {

        // ugliest line of code I've written in this entire project
        guard let _keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double,
              self.view.frame.origin.y == 0
        else { return }

        let keyboardSize = view.convert(_keyboardSize, from: view.window)

        UIView.animate(withDuration: keyboardAnimationDuration) {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard self.view.frame.origin.y != 0 else { return }
        
        // this is the most genius line of code. ever.
        guard let cell = dailyCollectionViewController.collectionView.visibleCells.first as? DailyCollectionViewCell,
              dailyCollectionViewController.isCancellingEditing || !cell.massTextField.isEditing,
              let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        UIView.animate(withDuration: keyboardAnimationDuration) {
            self.view.frame.origin.y = 0
        }
    }
    
    override func configure(cell: DayViewCell?, cellState: CellState) {
        super.configure(cell: cell, cellState: cellState)
    }
    
    override func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        super.calendar(calendar, didSelectDate: date, cell: cell, cellState: cellState)
        
        dailyCollectionViewController.scrollToItem(at: date, animated: true)
    }
    
    func dailyView(_ dailyView: UICollectionView, didScrollToItemAt date: Date) {
        calendarView.scrollToDate(date)
        calendarView.deselectAllDates()
        calendarView.selectDates([date])
    }
}
