//
//  DailyCSV.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 27/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation

fileprivate let dateFormatter: ISO8601DateFormatter = {
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = .withInternetDateTime
    return fmt
}()

/// Helper for import/export of CSV data from a bunch of Dailies.
class DailyCSV {
    
    // initial line of the CSV file -- title of each column
    private let header = "Date; Mass; Energy"
    
    // EU uses ";", USA uses ", "
    private let separator = "; "
    private let missingData = "missing data"
    private let measurementFormatter: MeasurementFormatter
    
    private var items: [Daily]
    
    init(measurementFormatter: MeasurementFormatter, items: [Daily]) {
        self.measurementFormatter = measurementFormatter
        self.items = items
    }
    
    func addItems(_ dailies: Daily...) {
        self.items.append(contentsOf: dailies)
    }
    
    private func stringify() -> String {
        return items.flatMap(convert).joined(separator: "\n")
    }
    
    func export() -> Data {
        return items
            .flatMap(convert)
            .joined(separator: "\n")
            .data(using: .utf8)!
    }
    
    // make a CSV representation of a Daily
    private func convert(_ daily: Daily) -> String? {
        guard let createdDate = daily.created else { return nil }
        
        let date = dateFormatter.string(from: createdDate)
        let mass = daily.mass.flatMap(measurementFormatter.string) ?? missingData
        let energy = daily.energy.flatMap(measurementFormatter.string) ?? missingData
        
        return [date, mass, energy].joined(separator: separator)
    }
}
