////
////  BasicCalendarViewController.swift
////  DailyBurner
////
////  Created by Dino Srdoč on 03/12/2017.
////  Copyright © 2017 Dino Srdoč. All rights reserved.
////
//
//import UIKit
//import JTAppleCalendar
//
//class CalendarViewController: UIViewController {
//    @IBOutlet weak var calendarView: JTAppleCalendarView! {
//        didSet {
//            setupDelegates()
//            setupCalendar()
//            scrollCalendar()
//            
//            calendarView.calendarDataSource = calendarDataSource
//            calendarView.calendarDelegate = calendarDelegate
//        }
//    }
//    @IBOutlet weak var monthLabel: UILabel!
//    @IBOutlet weak var yearLabel: UILabel!
//    
//    private lazy var dateFormatter: DateFormatter = {
//        let fmt = DateFormatter()
//        fmt.dateStyle = .long
//        return fmt
//    }()
//    let today = Date()
//    var selectedDate: Date?
//    
//    var calendarDataSource: CalendarDataSource?
//    var calendarDelegate: CalendarDelegate?
//    
//    func selectionHandler(date: Date, cell: JTAppleCell?) {
//        selectedDate = date
//    }
//    
//    func setupDelegates() {
//        calendarDataSource = CalendarDataSource(.weekly)
//        calendarDelegate = CalendarDelegate(onSelect: selectionHandler)
//        calendarDelegate?.onScroll = didScrollCalendar
//    }
//    
//    func setupCalendar() {
//        calendarView.minimumLineSpacing = 0
//        calendarView.minimumInteritemSpacing = 2
////        calendarView.cellSize = 60
////        calendarView.scrollingMode = .stopAtEachSection
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        dateFormatter.dateFormat = "MMMM"
//        monthLabel.text = dateFormatter.string(from: today)
//        dateFormatter.dateFormat = "yyyy"
//        yearLabel.text = dateFormatter.string(from: today)
//    }
//    
//    func didScrollCalendar(to date: Date) {
//        dateFormatter.dateFormat = "MMMM"
//        monthLabel.text = dateFormatter.string(from: date)
//        dateFormatter.dateFormat = "yyyy"
//        yearLabel.text = dateFormatter.string(from: date)
//    }
//    
//    func scrollCalendar() {
//        calendarView.scrollToDate(today, animateScroll: false)
//        calendarView.selectDates([today]/*, triggerSelectionDelegate: false*/)
//    }
//}
////
////  CalendarDataSource.swift
////  WeeklyBurner
////
////  Created by Dino Srdoč on 14/12/2017.
////  Copyright © 2017 Dino Srdoč. All rights reserved.
////
//
//import JTAppleCalendar
//
//class CalendarDataSource: JTAppleCalendarViewDataSource {
//    enum Configuration {
//        case monthly, weekly
//    }
//    
//    let startDate: Date
//    let endDate: Date
//    let firstDayOfWeek: DaysOfWeek
//    var numberOfRows: Int
//    var inDateGeneration: InDateCellGeneration
//    var strictBounds: Bool
//    
//    var yearCount: Int {
//        return Calendar.current.dateComponents([.year], from: startDate, to: endDate).year ?? 0
//    }
//    
//    private static let yearComponent = Calendar.current.dateComponents([.year], from: Date())
//    private static let beginningOfYear = Calendar.current.date(from: yearComponent)!
//    static let startingDate = Calendar.current.date(byAdding: .year, value: -20, to: beginningOfYear)!
//    static let endingDate = Calendar.current.date(byAdding: .year, value: 10, to: beginningOfYear)!
//    
//    private init(
//        startDate: Date = startingDate,
//        endDate: Date = endingDate,
//        firstDayOfWeek: DaysOfWeek = .monday,
//        numberOfRows: Int = 5,
//        inDateGeneration: InDateCellGeneration = .forAllMonths,
//        strictBounds: Bool)
//    {
//        self.startDate = startDate
//        self.endDate = endDate
//        self.firstDayOfWeek = firstDayOfWeek
//        self.numberOfRows = numberOfRows
//        self.inDateGeneration = inDateGeneration
//        self.strictBounds = strictBounds
//    }
//    
//    convenience init(_ config: Configuration) {
//        let numberOfRows: Int
//        let inDateGeneration: InDateCellGeneration
//        let strictBounds: Bool
//        
//        switch config {
//        case .monthly:
//            numberOfRows = 5
//            inDateGeneration = .forAllMonths
//            strictBounds = true
//        case .weekly:
//            numberOfRows = 1
//            inDateGeneration = .forFirstMonthOnly
//            strictBounds = false
//        }
//        
//        self.init(numberOfRows: numberOfRows, inDateGeneration: inDateGeneration, strictBounds: strictBounds)
//    }
//    
//    func reconfigure(to config: Configuration) {
//        switch config {
//        case .monthly:
//            numberOfRows = 5
//            inDateGeneration = .forAllMonths
//            strictBounds = true
//        case .weekly:
//            numberOfRows = 1
//            inDateGeneration = .forFirstMonthOnly
//            strictBounds = false
//        }
//    }
//    
//    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
//        return ConfigurationParameters(
//            startDate: startDate,
//            endDate: endDate,
//            numberOfRows: numberOfRows,
////            generateInDates: inDateGeneration,
//            generateOutDates: .tillEndOfRow,
//            firstDayOfWeek: firstDayOfWeek,
//            hasStrictBoundaries: strictBounds
//        )
//    }
//}
////
////  CalendarDelegate.swift
////  WeeklyBurner
////
////  Created by Dino Srdoč on 15/12/2017.
////  Copyright © 2017 Dino Srdoč. All rights reserved.
////
//
//import Foundation
//import JTAppleCalendar
//
//class CalendarDelegate: JTAppleCalendarViewDelegate {
//    struct Colors {
//        static let month = #colorLiteral(red: 0.1000000015, green: 0.1000000015, blue: 0.1000000015, alpha: 1)
//        static let selected = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        static let current = #colorLiteral(red: 0.9549999833, green: 0.3140000105, blue: 0.4199999869, alpha: 1)
//        static let outside = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//    }
//    
//    var onSelect: (Date, JTAppleCell?) -> Void
//    var onScroll: ((Date) -> Void)?
//    private let today: Date
//    
//    init(onSelect: @escaping (Date, JTAppleCell?) -> Void) {
//        self.today = Date()
//        self.onSelect = onSelect
//    }
//    
//    func handleColor(_ calendar: JTAppleCalendarView, for cell: DayViewCell, with cellState: CellState) {
//        if calendar.selectedDates.contains(cellState.date) {
//            cell.dayLabel.textColor = Colors.selected
//        } else if Calendar.current.isDateInToday(cellState.date) {
//            cell.dayLabel.textColor = Colors.current
//        } else if cellState.dateBelongsTo == .thisMonth {
//            cell.dayLabel.textColor = Colors.month
//        } else {
//            cell.dayLabel.textColor = Colors.outside
//        }
//    }
//    
//    func configure(_ calendar: JTAppleCalendarView, cell: DayViewCell, with cellState: CellState) {
////        if cellState.dateBelongsTo == .previousMonthOutsideBoundary {
////            cell.isHidden = true
////        }
////        if cellState.dateBelongsTo == .thisMonth && calendar. {
////            cell.isHidden = true
////        }
//        cell.selectionView.isHidden = !calendar.selectedDates.contains(cellState.date)
//        cell.dayLabel.text = cellState.text
//        
//        handleColor(calendar, for: cell, with: cellState)
//    }
//    
//    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
//        guard let cell = cell as? DayViewCell else { return }
//        configure(calendar, cell: cell, with: cellState)
//    }
//    
//    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
//        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "DayViewCell", for: indexPath) as? DayViewCell else {
//            return JTAppleCell()
//        }
//        configure(calendar, cell: cell, with: cellState)
//        
//        return cell
//    }
//    
//    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
//        guard let cell = cell as? DayViewCell else { return }
//        
//        configure(calendar, cell: cell, with: cellState)
//        onSelect(date, cell)
//    }
//    
//    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
//        guard let cell = cell as? DayViewCell else { return }
//        
//        configure(calendar, cell: cell, with: cellState)
//    }
//    
//    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
//        guard cellState.dateBelongsTo == .thisMonth else {
//            return false
//        }
//        
//        return true
//    }
//    
//    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
//        let date = visibleDates.monthDates.first!.date
//        onScroll?(date)
//    }
//}
//
//class MonthlyCalendarDelegate: CalendarDelegate {
//    private let monthFormatter: DateFormatter = {
//        let fmt = DateFormatter()
//        fmt.dateFormat = "MMMM"
//        
//        return fmt
//    }()
//    
//    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
//        guard let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "Header", for: indexPath) as? CalendarHeader else {
//            return JTAppleCollectionReusableView()
//        }
//        
//        header.title = monthFormatter.string(from: range.start)
//        
//        return header
//    }
//    
//    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
//        return MonthSize(defaultSize: 50)
//    }
//}

