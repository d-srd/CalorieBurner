//
//  ChartsViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 22/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import Charts

class ChartsViewController: UIViewController {
    @IBOutlet weak var massChartView: LineChartView!
    @IBOutlet weak var energyChartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())!
        let endDate = Date()
        
        guard let dailies = try? CoreDataStack.shared.fetch(betweenStartDate: startDate, endDate: endDate) else { return }
        
        
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
        
        let massDataSet = LineChartDataSet(values: massDataValues, label: "Weight")
        massDataSet.mode = .cubicBezier
        massDataSet.colors = ChartColorTemplates.vordiplom()
        let massData = LineChartData(dataSet: massDataSet)
        
        let energyDataSet = LineChartDataSet(values: energyDataValues, label: "Energy")
        energyDataSet.mode = .cubicBezier
        energyDataSet.colors = ChartColorTemplates.liberty()
        let energyData = LineChartData(dataSet: energyDataSet)
        
        massChartView.data = massData
        energyChartView.data = energyData
        
    }
}
