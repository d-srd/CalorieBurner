//
//  Date.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 04/04/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    // warning: this will break in some cases.
    // TODO: find a stable solution
    var endOfDay: Date {
        let components = DateComponents(day: 1, second: -1)
        return Calendar.current.date(byAdding: components, to: self)!
    }
}

extension Date {
    var startOfWeek: Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}
