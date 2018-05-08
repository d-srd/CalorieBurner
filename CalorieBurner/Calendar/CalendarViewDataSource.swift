//
//  CalendarViewDataSource.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 08/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import JTAppleCalendar

/// Preconfigured Calendar Data Source equipped for dealing with weekly/monthly Calendar Views. Weekly Calendar Views have only a single row, whilst Monthly Calendar Views have multiple.
class CalendarViewDataSource: JTAppleCalendarViewDataSource, DateBoundaries {
    enum Configuration { case weekly, monthly }
    
    let dateFormatter = DateFormatter()
    var configuration: Configuration
    var firstDayOfWeek: DaysOfWeek = .monday
    
    lazy var startDate: Date = {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: "2000-01-01")!
    }()
    
    lazy var endDate: Date = {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: "2030-12-31")!
    }()
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
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
