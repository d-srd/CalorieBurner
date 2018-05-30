//
//  CalendarViewDataSource.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 08/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import JTAppleCalendar

/// Preconfigured Calendar Data Source equipped for dealing with weekly/monthly Calendar Views. 
class CalendarViewDataSource: JTAppleCalendarViewDataSource, DateBoundaries {
    enum Configuration {
        case weekly
        case monthly
    }
    
    let dateFormatter = DateFormatter()
    var configuration: Configuration
    var firstDayOfWeek = DaysOfWeek(rawValue: UserDefaults.standard.firstDayOfWeek)!
    
    // TODO: make sure this doesn't break in certain locales
    var startDate: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 01, day: 01))!
    var endDate: Date = Calendar.current.date(from: DateComponents(year: 2030, month: 31, day: 12))!
    
    init(configuration: Configuration) {
        self.configuration = configuration
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(firstDayOfWeekDidChange(_:)),
            name: .FirstDayOfWeekDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .FirstDayOfWeekDidChange, object: nil)
    }
    
    @objc private func firstDayOfWeekDidChange(_ notification: Notification) {
        let newFirstDayOfWeek = UserDefaults.standard.firstDayOfWeek
        
        firstDayOfWeek = DaysOfWeek(rawValue: newFirstDayOfWeek)!
    }
    
    /// Configures weekly view to show a single row with no overlapping dates and monthly views to display all dates with one row per week
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        if configuration == .weekly {
            return ConfigurationParameters(startDate: startDate,
                                           endDate: endDate,
                                           numberOfRows: 1,
                                           generateInDates: .forFirstMonthOnly,
                                           generateOutDates: .off,
                                           firstDayOfWeek: firstDayOfWeek,
                                           hasStrictBoundaries: false)
        } else {
            return ConfigurationParameters(startDate: startDate,
                                           endDate: endDate,
                                           generateOutDates: .tillEndOfRow,
                                           firstDayOfWeek: firstDayOfWeek,
                                           hasStrictBoundaries: false)
        }
    }
}
