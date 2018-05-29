//
//  File.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 18/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import JTAppleCalendar

private extension JTAppleCalendarView {
    func reloadDate(_ date: Date) {
        self.reloadDates([date])
    }
}

class DailyCalendarViewController: CalendarViewController, DailyCollectionViewScrollDelegate {
    
    enum Segues: String {
        case inputVC = "DailyInputSegue"
        case collectionVC = "DailyCollectionViewSegue"
        case monthlyCalendarVC = "MonthlyCalendarViewSegue"
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var fullDateLabel: UILabel!
    
    var dailyCollectionViewController: DailyCollectionViewController!
    var currentDate: Date? {
        get { return calendarView.selectedDates.first }
        set {
            guard let date = newValue else { return }
            calendarView.deselectAllDates()
            calendarView.scrollToDate(date)
            calendarView.selectDates([date], triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: false)
            dailyCollectionViewController.scrollToItem(at: date, animated: false)
        }
    }
    
    @IBAction func showDailyInputViewController(_ sender: Any) {
        performSegue(withIdentifier: Segues.inputVC.rawValue, sender: sender)
    }
    
    @IBAction func showMonthlyCalendar(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segues.monthlyCalendarVC.rawValue, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let identifier = segue.identifier,
              let identifierCase = Segues.init(rawValue: identifier)
        else { fatalError("Segue not implemented") }
        
        switch identifierCase {
        case .collectionVC:
            let dailyCollection = segue.destination as! DailyCollectionViewController
            dailyCollectionViewController = dailyCollection
            dailyCollectionViewController.view.autoresizingMask = []
            dailyCollectionViewController.view.frame = containerView.bounds
            
        case .inputVC:
            // there's a navigation controller in here, so we steal its child
            let inputVC = segue.destination.childViewControllers.first as! DailyInputViewController
            inputVC.date = calendarView.selectedDates.first
            inputVC.delegate = self
            
        case .monthlyCalendarVC:
            let calendarVC = segue.destination.childViewControllers.first as! CalendarViewController
            calendarVC.configuration = .monthly
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setDailyVCItemSize()
        dailyCollectionViewController.dailyView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    private func reloadData() {
        dailyCollectionViewController.reloadData()
        currentDate.flatMap(calendarView.reloadDate)
    }
    
    private func setDailyVCItemSize() {
        dailyCollectionViewController.dailyView.itemSize =
            CGSize(width: containerView.frame.width * 0.8, height: 240)
    }
    
    private func configureDailyVCInitial() {
        setDailyVCItemSize()
        dailyCollectionViewController.dailyView.dailyScrollDelegate = self
        dailyCollectionViewController.scrollToItem(at: self.today, animated: false)
        calendarView.selectDates([today])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuration = .weekly
        setCurrentDateLabel(to: today)
        
        configureDailyVCInitial()
        
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: .UIKeyboardWillHide,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UnitMassChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UnitEnergyChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // Fix collection view layout. Without this, the content inset wouldn't change and the cell would stay on the upper side of the screen
    @objc private func keyboardWillHide(_ notification: Notification) {
        dailyCollectionViewController.dailyView.collectionViewLayout.invalidateLayout()
    }
    
    @objc private func unitsDidChange(_ notification: Notification) {
        dailyCollectionViewController.reloadData()
    }
    
    private func setCurrentDateLabel(to date: Date) {
        dateFormatter.dateFormat = fullDateFormat
        fullDateLabel.text = dateFormatter.string(from: date)
    }
    
    private func setCurrentMonthTitle(to date: Date) {
        dateFormatter.dateFormat = monthDateFormat
        navigationItem.backBarButtonItem?.title = dateFormatter.string(from: date)
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
        
        setCurrentDateLabel(to: date)
        setCurrentMonthTitle(to: date)
        
        dailyCollectionViewController.scrollToItem(at: date, animated: true)
        
        // disable adding dailies if they are beyond today
        navigationItem.rightBarButtonItem?.isEnabled = date < today
    }
    
    func dailyView(_ dailyView: DailyCollectionView, willScrollToItemAt date: Date) {
        // empty implementation, as this is not an Objective-C protocol with optional methods
    }
    
    func dailyView(_ dailyView: DailyCollectionView, didScrollToItemAt date: Date) {
        if !calendarView.selectedDates.contains(date) {
            calendarView.scrollToDate(date)
            calendarView.deselectAllDates()
            calendarView.selectDates([date])
        }
    }
    
    
}

extension DailyCalendarViewController: DailyInputViewControllerDelegate {
    func didSaveDaily() {
        reloadData()
    }
}
