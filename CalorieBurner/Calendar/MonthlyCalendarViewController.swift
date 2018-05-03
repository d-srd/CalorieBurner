//
//  MonthlyCalendarViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 13/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol DailyCalendarDelegate {
    func doesItemExist(at date: Date) -> Bool
}

class MonthlyCalendarViewController: UIViewController, JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
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
    @IBOutlet weak var fullDateLabel: UILabel!
    
    private var weekdayLabels: [UILabel] {
        return weekdaysStackView.subviews.map { $0 as! UILabel }
    }
    
    // MARK: Properties
    
    let animationSelectionDuration = 0.3
    
    // used for month, year, and days of week labels
    private let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        
        return fmt
    }()
    
    // used for fullDateLabel, i.e. the tiny label just under the calendar
    private let fullDateFormat = "MMMM dd, YYYY"
    private let monthDateFormat = "MMMM"
    
    let today = Date()
    
    lazy var startDate: Date = {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: "2000-01-01")!
    }()
    lazy var endDate: Date = {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: "2030-12-31")!
    }()
    
    // offset from `Calendar.firstWeekday` by -1
    var firstDayOfWeek: DaysOfWeek = .monday {
        didSet {
            setWeekdayLabels()
            calendarView.reloadData()
            calendarView.scrollToDate(today)
        }
    }
    
    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        calendarView.scrollingMode = .stopAtEachSection
        
        setWeekdayLabels()
        setCurrentDateLabel(to: today)
        
        calendarView.scrollToDate(today)
    }
    
    private func setCurrentDateLabel(to date: Date) {
        dateFormatter.dateFormat = fullDateFormat
        fullDateLabel.text = dateFormatter.string(from: date)
    }
    
    private func setCurrentMonthTitle(to date: Date) {
        dateFormatter.dateFormat = monthDateFormat
        navigationItem.title = dateFormatter.string(from: date)
    }
    
    private func setWeekdayLabels() {
        let daySymbols = Calendar.current.shortStandaloneWeekdaySymbols
        
        // why is this 8 - day.rawValue? Nobody knows. it works.
        let startDayDistance = 8 - firstDayOfWeek.rawValue
        
        for (index, label) in weekdayLabels.rotatedRight(by: startDayDistance).enumerated() {
            label.text = daySymbols[index]
        }
    }

    // MARK: JTAppleCalendarViewDataSource
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(
            startDate: startDate,
            endDate: endDate,
            numberOfRows: 1,
            generateInDates: .forFirstMonthOnly,
            generateOutDates: .off,
            firstDayOfWeek: firstDayOfWeek,
            hasStrictBoundaries: false
        )
    }
    

    // MARK: JTAppleCalendarViewDelegate
    
    func configure(cell: DayViewCell?, cellState: CellState, animated: Bool) {
        guard let cell = cell else { return }
        
        // text
        cell.dayLabel.text = cellState.text
        
        // handle cell selection and animation
        if calendarView.selectedDates.contains(cellState.date) {
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
                        } else {
                            cell.dayLabel.textColor = Colors.outMonth
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
                } else {
                    cell.dayLabel.textColor = Colors.outMonth
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
    
//    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
//        guard let date = visibleDates.monthDates.first?.date else { return }
//
//        dateFormatter.dateFormat = "MMMM yyyy"
////        navigationItem.title = dateFormatter.string(from: date)
//
////        setCurrentDateLabel(to: date)
//
////        setDateLabels(to: date)
//    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        return cellState.dateBelongsTo == .thisMonth
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configure(cell: map(cell), cellState: cellState, animated: true)
        setCurrentDateLabel(to: date)
        setCurrentMonthTitle(to: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configure(cell: map(cell), cellState: cellState, animated: true)
    }
}
