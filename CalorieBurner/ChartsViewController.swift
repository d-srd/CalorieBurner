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
    @IBOutlet weak var chartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let values = (0...7).map { ChartDataEntry(x: Double($0), y: sin(Double($0)))}
        
        let dataSet = LineChartDataSet(values: values, label: nil)
        dataSet.mode = .cubicBezier
        let data = LineChartData(dataSet: dataSet)
        
        chartView.data = data
        
    }
}
