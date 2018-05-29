//
//  MonthlyCalendarViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 13/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import JTAppleCalendar

extension UIColor {
    static var healthyRed = #colorLiteral(red: 0.9549999833, green: 0.3140000105, blue: 0.4199999869, alpha: 1)
}

protocol DailyCalendarDelegate {
    func doesItemExist(at date: Date) -> Bool
}

class CalendarViewController: UIViewController, JTAppleCalendarViewDelegate {
    
    // MARK: Types
    
    struct Colors {
        static let today = #colorLiteral(red: 0.9549999833, green: 0.3140000105, blue: 0.4199999869, alpha: 1)
        static let currentMonth = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        static let outMonth = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        static let selected = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    // MARK: IB Outlets
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var weekdaysStackView: UIStackView!
    
    // MARK: Properties
    
    private let dataSource = CalendarViewDataSource(configuration: .weekly)

    /// Duration of animating a selection view (dis)appearing & text color changes, in seconds
    let animationSelectionDuration = 0.3
    
    let today = Date()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
    
    let fullDateFormat = "MMMM dd, YYYY"
    let monthDateFormat = "MMMM"
    
    var configuration: CalendarViewDataSource.Configuration {
        get { return dataSource.configuration }
        set { dataSource.configuration = newValue}
    }
    
    private var weekdayLabels: [UILabel] {
        return weekdaysStackView.subviews.map { $0 as! UILabel }
    }
    
    // offset from `Calendar.firstWeekday` by -1
    var firstDayOfWeek: DaysOfWeek {
        get {
            return dataSource.firstDayOfWeek
        }
        set {
            dataSource.firstDayOfWeek = newValue
            setWeekdayLabels()
            calendarView.reloadData()
            calendarView.scrollToDate(today)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = dataSource
        calendarView.scrollingMode = .stopAtEachSection
        
        setWeekdayLabels()
        
        calendarView.scrollToDate(today)
        
        if configuration == .monthly {
            let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissCalendar(_:)))
            item.tintColor = UIColor.healthyRed
            navigationItem.setRightBarButton(item, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToWeeklySegue" {
            let dailyController = segue.destination as! DailyCalendarViewController
            dailyController.currentDate = calendarView.selectedDates.first!
        }
    }
    
    @objc private func dismissCalendar(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setWeekdayLabels() {
        let daySymbols = Calendar.current.shortStandaloneWeekdaySymbols
        
        // how many indices to move to get first day of week to the first position in the calendar view
        let startDayDistance = 8 - firstDayOfWeek.rawValue
        
        // set labels such that the value of `firstDayOfWeek` is in the first label
        for (index, label) in weekdayLabels.rotatedRight(by: startDayDistance).enumerated() {
            label.text = daySymbols[index]
        }
    }

    // MARK: JTAppleCalendarViewDelegate
    
    // TODO: separate the inner condition operations into their own methods
    func configure(cell: DayViewCell?, cellState: CellState, animated: Bool) {
        guard let cell = cell else { return }
        
        cell.dayLabel.text = cellState.text
        
        // handle cell selection and animation
        if calendarView.selectedDates.contains(cellState.date), cellState.dateBelongsTo == .thisMonth {
            cell.selectionView.isHidden = false

            if animated {
                UIView.animate(withDuration: animationSelectionDuration) {
                    cell.selectionView.alpha = 1
                }
                
                // UILabel text color cannot be implicitly animated, therefore we use the block below
                UIView.transition(
                    with: cell.dayLabel,
                    duration: animationSelectionDuration,
                    options: .transitionCrossDissolve,
                    animations: { cell.dayLabel.textColor = Colors.selected },
                    completion: nil
                )
            } else {
                cell.selectionView.alpha = 1
                cell.dayLabel.textColor = Colors.selected
            }
        } else {
            if animated {
                UIView.animate(
                    withDuration: animationSelectionDuration,
                    animations: { cell.selectionView.alpha = 0 },
                    completion: { _ in cell.selectionView.isHidden = true }
                )
                
                UIView.transition(
                    with: cell.dayLabel,
                    duration: animationSelectionDuration,
                    options: .transitionCrossDissolve,
                    animations: {
                        if Calendar.current.isDateInToday(cellState.date) {
                            cell.dayLabel.textColor = Colors.today
                        } else if cellState.dateBelongsTo == .thisMonth {
                            cell.dayLabel.textColor = Colors.currentMonth
                        } else if self.configuration == .weekly {
                            cell.dayLabel.textColor = Colors.outMonth
                        } else {
                            cell.dayLabel.textColor = UIColor.white
                        }
                    },
                    completion: nil
                )
            } else {
                cell.selectionView.alpha = 0
                cell.selectionView.isHidden = true
                
                if Calendar.current.isDateInToday(cellState.date) {
                    cell.dayLabel.textColor = Colors.today
                } else if cellState.dateBelongsTo == .thisMonth {
                    cell.dayLabel.textColor = Colors.currentMonth
                } else if configuration == .weekly {
                    cell.dayLabel.textColor = Colors.outMonth
                } else {
                    cell.dayLabel.textColor = UIColor.white
                }
            }
        }
    }
    
    func map(_ cell: JTAppleCell?) -> DayViewCell? {
        return cell as? DayViewCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? DayViewCell else { return }
        
        configure(cell: cell, cellState: cellState, animated: false)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "DayViewCell", for: indexPath) as? DayViewCell else {
            return JTAppleCell()
        }
        
        configure(cell: cell, cellState: cellState, animated: false)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        return cellState.dateBelongsTo == .thisMonth
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configure(cell: map(cell), cellState: cellState, animated: true)
        if configuration == .monthly {
            performSegue(withIdentifier: "unwindToWeeklySegue", sender: self)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configure(cell: map(cell), cellState: cellState, animated: true)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "MonthHeaderView", for: indexPath) as! MonthHeaderView
        dateFormatter.dateFormat = monthDateFormat
        header.monthIndicatorLabel.text = dateFormatter.string(from: range.start)
        
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        if configuration == .monthly {
            return MonthSize(defaultSize: 50)
        } else {
            return nil
        }
    }
}
