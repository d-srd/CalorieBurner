//
//  CoreDataMediator.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 09/06/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Charts

class CoreDataMediator: LineChartViewDelegate {
    typealias Data = (mass: [ChartDataEntry], energy: [ChartDataEntry])?
    
    var startDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())!
    var endDate = Date()
    
    var massData: [ChartDataEntry] = []
    var energyData: [ChartDataEntry] = []
    
    func update(view: LineChartView) {
        (massData, energyData) = fetchData(for: view) ?? ([], [])
    }
    
    func fetchData(for chartView: LineChartView) -> Data {
        guard let dailies = try? CoreDataStack.shared.fetch(betweenStartDate: startDate, endDate: endDate) else { return nil }
        
        var massDataValues = [ChartDataEntry]()
        var energyDataValues = [ChartDataEntry]()
        
        for daily in dailies {
            let index = Calendar.current.dateComponents([.day], from: startDate, to: daily.created!).day!
            if let mass = daily.mass {
                massDataValues.append(ChartDataEntry(x: Double(index), y: mass.value) )
            }
            if let energy = daily.energy {
                energyDataValues.append(ChartDataEntry(x: Double(index), y: energy.value))
            }
        }
        
        // charts expects sorted data.
        massDataValues.sort { $0.x < $1.x }
        energyDataValues.sort { $0.x < $1.x }
        
        return (massDataValues, energyDataValues)
    }
}
