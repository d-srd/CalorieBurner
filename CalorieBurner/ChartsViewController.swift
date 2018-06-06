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

class ChartViewController: UIViewController {
    private lazy var formatter = ShortDateChartFormatter(startDate: dataSource?.startDate ?? defaultDate)
    private let defaultDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())!
    private var chartView: LineChartView!
    var dataSource: CoreDataMediator?
    var type: MeasurementItems?
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        chartView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        chartView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        chartView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        chartView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartView = LineChartView(frame: view.bounds)
        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        chartView.legend.enabled = false
        chartView.xAxis.valueFormatter = formatter
        chartView.chartDescription?.text = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChart()
    }
}

class ExpandedPageViewController: UIPageViewController {
    var pageControl: UIPageControl? {
        return view.subviews.first { $0 is UIPageControl } as? UIPageControl
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let scrollView = view.subviews.first { $0 is UIScrollView }
        
        if let scrollView = scrollView, let pageControl = pageControl {
            scrollView.frame = view.bounds
            view.bringSubview(toFront: pageControl)
        }
    }
}

class ChartsPageViewController: ExpandedPageViewController {
    private(set) lazy var pages = makePages()
    
    private let pageDataSource = CoreDataMediator()
    
    private func makePages() -> [ChartViewController] {
        let massController = ChartViewController()
        massController.dataSource = pageDataSource
        massController.type = .mass
        let energyController = ChartViewController()
        energyController.dataSource = pageDataSource
        energyController.type = .energy
        
        return [massController, energyController]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        pageControl?.currentPageIndicatorTintColor = .healthyRed
        pageControl?.pageIndicatorTintColor = .lightGray
        
        delegate = self
        dataSource = self
        
        setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
    }
}

extension ChartsPageViewController: UIPageViewControllerDelegate {
    
}

extension ChartsPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.index(of: viewController as! ChartViewController), index != pages.startIndex else { return nil }
        
        return pages[pages.index(before: index)]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.index(of: viewController as! ChartViewController), index != pages.index(before: pages.endIndex) else { return nil }
        
        return pages[pages.index(after: index)]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
