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
    
    // MARK: Private objects
    
    struct Colors {
        static let today = #colorLiteral(red: 0.9549999833, green: 0.3140000105, blue: 0.4199999869, alpha: 1)
        static let currentMonth = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        static let outMonth = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        static let selected = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    // MARK: IB Outlets
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet var weekdayLabels: [UILabel]!
    
    // MARK: Properties
    
    // used for month, year, and days of week labels
    private let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        
        return fmt
    }()
    private let today = Date()
    
    lazy var startDate = dateFormatter.date(from: "2000-01-01")!
    lazy var endDate = dateFormatter.date(from: "2030-12-31")!
    
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
        
//        calendarView.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        calendarView.scrollingMode = .stopAtEachSection
        
        setWeekdayLabels()
        setDateLabels(to: today)
        
        calendarView.scrollToDate(today)
        
    }
    
    // don't think about this one for too long
    @IBAction func setFirstDayOfWeek(_ sender: UIButton) {
        switch sender.currentTitle {
        case "mon"?: firstDayOfWeek = .monday
        case "tue"?: firstDayOfWeek = .tuesday
        case "wed"?: firstDayOfWeek = .wednesday
        case "thu"?: firstDayOfWeek = .thursday
        case "fri"?: firstDayOfWeek = .friday
        case "sat"?: firstDayOfWeek = .saturday
        case "sun"?: firstDayOfWeek = .sunday
        default: break
        }
    }
    
    private func setWeekdayLabels() {
        let daySymbols = Calendar.current.shortStandaloneWeekdaySymbols
        
        // why is this 8 - day.rawValue? Nobody knows. it works.
        let startDayDistance = 8 - firstDayOfWeek.rawValue
        
//        for (index, label) in weekdayLabels.rotatedRight(by: startDayDistance).enumerated() {
//            label.text = daySymbols[index]
//        }
        for (index, daySymbol) in daySymbols.rotatedRight(by: startDayDistance).enumerated() {
            weekdayLabels[index].text = daySymbol
        }
    }
    
    private func setDateLabels(to date: Date) {
        dateFormatter.dateFormat = "MMMM"
        monthLabel.text = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyy"
        yearLabel.text = dateFormatter.string(from: date)
        
    }
    

    // MARK: JTAppleCalendarViewDataSource
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(
                    startDate: startDate,
                    endDate: endDate,
                    generateOutDates: .tillEndOfRow,
                    firstDayOfWeek: firstDayOfWeek
                )
    }
    

    // MARK: JTAppleCalendarViewDelegate
    
    func configure(cell: DayViewCell?, cellState: CellState) {
        guard let cell = cell else { return }
        
        // text
        cell.dayLabel.text = cellState.text
        
        // handle cell selection
        if calendarView.selectedDates.contains(cellState.date) {
            cell.selectionView.isHidden = false
            
            UIView.animate(withDuration: 0.2) {
                cell.selectionView.alpha = 1
                cell.dayLabel.textColor = Colors.selected
            }
        } else {
            UIView.animate(
                withDuration: 0.2,
                animations: { cell.selectionView.alpha = 0 },
                completion: { _ in cell.selectionView.isHidden = true }
            )
            
            if Calendar.current.isDateInToday(cellState.date) {
                cell.dayLabel.textColor = Colors.today
            } else if cellState.dateBelongsTo == .thisMonth {
                cell.dayLabel.textColor = Colors.currentMonth
            } else {
                cell.dayLabel.textColor = Colors.outMonth
            }
        }
    }
    
    func map(_ cell: JTAppleCell?) -> DayViewCell? {
        return cell as? DayViewCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? DayViewCell else { return }
        
        configure(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "DayViewCell", for: indexPath) as? DayViewCell else {
            return JTAppleCell()
        }
        
        configure(cell: cell, cellState: cellState)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        
        setDateLabels(to: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        guard cellState.dateBelongsTo == .thisMonth else {
            return false
        }
        
        return true
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configure(cell: map(cell), cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configure(cell: map(cell), cellState: cellState)
    }
}
