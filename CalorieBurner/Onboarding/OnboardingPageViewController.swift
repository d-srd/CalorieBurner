//
//  OnboardingViewController.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 20/05/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {
    weak var onboardingDelegate: OnboardingViewControllerDelegate?
    var pages: [OnboardingViewController]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        delegate = self
        dataSource = self
        
        let tempPages = [
            storyboard?.instantiateViewController(withIdentifier: "PageOne"),
            storyboard?.instantiateViewController(withIdentifier: "PageTwo"),
            storyboard?.instantiateViewController(withIdentifier: "PageThree")
        ]
        
        pages = tempPages.compactMap { $0 as? OnboardingViewController }
        
        for page in pages {
            page.delegate = onboardingDelegate
        }
        
        view.backgroundColor = .white
        
        setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageControl?.currentPageIndicatorTintColor = .healthyRed
        pageControl?.pageIndicatorTintColor = .lightGray
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.index(of: viewController as! OnboardingViewController), index != pages.startIndex else { return nil }
        
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.index(of: viewController as! OnboardingViewController), index != pages.endIndex - 1 else { return nil }
        
        return pages[index + 1]
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
}
