//
//  DailyCollectionViewProtocols.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 02/04/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation

protocol DateBoundaries {
    var startDate: Date { get }
    var endDate: Date { get }
}

/// The object which provides conversions between IndexPaths and Dates for the associated Daily Collection View
protocol DailyIndexPathProvider: AnyObject {
    func indexPath(for date: Date) -> IndexPath?
    func date(for indexPath: IndexPath) -> Date?
}

/// Object to be notified of DailyCollectionView lifecycle events.
protocol DailyCollectionViewDelegate: AnyObject {
    func dailyView(_ dailyView: DailyCollectionView, willDisplay cell: DailyCollectionViewCell, forItemAt indexPath: IndexPath)

    func didEndEditing(cell: DailyDataCollectionViewCell, at date: Date, mass: Mass)
    func didEndEditing(cell: DailyDataCollectionViewCell, at date: Date, energy: Energy)
    func didEndEditing(cell: DailyDataCollectionViewCell, at date: Date, mood: Feelings)
}

protocol DailyCollectionViewDataSource: AnyObject, DateBoundaries {
    var dayCount: Int { get }
    
    func dailyView(_ dailyView: DailyCollectionView, cellForItemAt indexPath: IndexPath) -> DailyCollectionViewCell
}

/// The object which responds to Daily Collection View's scrolling notifications.
@objc protocol DailyCollectionViewScrollDelegate: class {
    @objc optional func dailyView(_ dailyView: DailyCollectionView, didScrollToItemAt date: Date)
    @objc optional func dailyView(_ dailyView: DailyCollectionView, willScrollToItemAt date: Date)
}
