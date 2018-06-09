//
//  ShortDateChartFormatter.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 09/06/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Charts

class ShortDateChartFormatter: IAxisValueFormatter {
    var startDate: Date
    let formatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM dd"
        return fmt
    }()
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Calendar.current.date(byAdding: .day, value: Int(value), to: startDate)
        return formatter.string(from: date!)
    }
    
    init(startDate: Date) {
        self.startDate = startDate
    }
}
