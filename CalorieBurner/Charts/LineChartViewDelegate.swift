//
//  LineChartViewDelegate.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 09/06/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Charts

protocol LineChartViewDelegate: AnyObject, DateBoundaries {
    associatedtype Data
    func fetchData(for chartView: LineChartView) -> Data
    func makeData(for chartView: LineChartView, values: [ChartDataEntry], label: String?) -> LineChartData
}

extension LineChartViewDelegate {
    func makeData(for chartView: LineChartView, values: [ChartDataEntry], label: String? = nil) -> LineChartData {
        let dataSet = LineChartDataSet(values: values, label: label)
        dataSet.mode = .cubicBezier
        dataSet.colors = ChartColorTemplates.joyful()
        dataSet.lineWidth = 5
        
        return LineChartData(dataSet: dataSet)
    }
}
