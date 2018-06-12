//
//  UIPageViewController+pageControl.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 12/06/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

public extension UIPageViewController {
    var pageControl: UIPageControl? {
        return view.subviews.first { $0 is UIPageControl } as? UIPageControl
    }
}
