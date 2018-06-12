//
//  ChartsPageViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 09/06/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

class ChartsPageViewController: UIPageViewController {
    private(set) lazy var pages = makePages()
    
    private func makePages() -> [ChartViewController] {
        let massPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
        let energyPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
        
        massPage.dataSource = pageDataSource
        massPage.type = .mass
        // accessing view property of a view controller loads its IBOutlets, which are needed to set the title
        massPage.view = massPage.view
        massPage.chartTitle = "Mass"
        
        energyPage.dataSource = pageDataSource
        energyPage.type = .energy
        energyPage.view = energyPage.view
        energyPage.chartTitle = "Energy"
        
        return [massPage, energyPage]
    }
    
    private let pageDataSource = CoreDataMediator()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageControl?.currentPageIndicatorTintColor = .healthyRed
        pageControl?.pageIndicatorTintColor = .lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
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
