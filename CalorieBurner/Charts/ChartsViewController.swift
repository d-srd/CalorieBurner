//
//  ChartsViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 22/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import Charts

class ChartViewController: UIViewController {
    @IBOutlet private weak var chartView: LineChartView!
    @IBOutlet private weak var chartTitleLabel: UILabel!
    
    private lazy var formatter = ShortDateChartFormatter(startDate: dataSource?.startDate ?? defaultDate)
    private let defaultDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())!
    
    var dataSource: CoreDataMediator?
    var type: MeasurementItems?
    
    var chartTitle: String? {
        get { return chartTitleLabel.text }
        set { chartTitleLabel.text = newValue }
    }
    
    private func updateChart() {
        dataSource?.update(view: chartView)
        
        let data: [ChartDataEntry]
        
        switch type {
        case .mass?:
            guard let _data = dataSource?.massData else { return }
            data = _data
        case .energy?:
            guard let _data = dataSource?.energyData else { return }
            data = _data
        default:
            return
        }
        
        chartView.data = dataSource?.makeData(for: chartView, values: data)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartView.legend.enabled = false
        chartView.xAxis.valueFormatter = formatter
        chartView.chartDescription?.text = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChart()
    }
}
