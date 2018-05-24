//
//  ChartsViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 22/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
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

class ChartsViewController: UIViewController {
    @IBOutlet weak var massChartView: LineChartView!
    @IBOutlet weak var energyChartView: LineChartView!
    
    let startDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())!
    let endDate = Date()
    
    private func fetchLatestData() -> (mass: [ChartDataEntry], energy: [ChartDataEntry])? {
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
    
    private func makeData(with entries: [ChartDataEntry], labeled label: String? = nil) -> LineChartData {
        let dataSet = LineChartDataSet(values: entries, label: label)
        dataSet.mode = .cubicBezier
        dataSet.colors = ChartColorTemplates.joyful()
        dataSet.lineWidth = 5
        
        return LineChartData(dataSet: dataSet)
    }
    
    private func updateCharts() {
        guard let (massData, energyData) = fetchLatestData() else { return }
        
        massChartView.data = makeData(with: massData)
        energyChartView.data = makeData(with: energyData)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = ShortDateChartFormatter(startDate: startDate)

        massChartView.legend.enabled = false
        energyChartView.legend.enabled = false
        massChartView.xAxis.valueFormatter = formatter
        energyChartView.xAxis.valueFormatter = formatter
        massChartView.chartDescription?.text = nil
        energyChartView.chartDescription?.text = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCharts()
    }
}
