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
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dailyCollectionViewController.cellWidth = containerView.frame.width * 0.7
        dailyCollectionViewController.cellHeight = 140 /* containerView.frame.height * 0.9 */
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
    
    func dailyView(_ dailyView: UICollectionView, didScrollToItemAt date: Date) {
        if !calendarView.selectedDates.contains(date) {
            calendarView.scrollToDate(date)
            calendarView.deselectAllDates()
            calendarView.selectDates([date])
        }
    }
}
