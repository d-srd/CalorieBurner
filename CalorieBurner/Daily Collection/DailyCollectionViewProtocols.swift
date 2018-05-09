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
protocol DailyIndexPathProvider: class {
    func indexPath(for date: Date) -> IndexPath?
    func date(for indexPath: IndexPath) -> Date?
}

/// Get notified of super cool DailyCollectionView lifecycle events
protocol DailyCollectionViewDelegate: class {
    func dailyView(_ dailyView: DailyCollectionView, willDisplay cell: DailyCollectionViewCell, forItemAt indexPath: IndexPath)

    func willCancelEditing(cell: DailyDataCollectionViewCell, at date: Date, for itemType: MeasurementItems)
    func didCancelEditing(cell: DailyDataCollectionViewCell, at date: Date, for itemType: MeasurementItems)
    func didEndEditing(cell: DailyDataCollectionViewCell, at date: Date, mass: Mass)
    func didEndEditing(cell: DailyDataCollectionViewCell, at date: Date, energy: Energy)
    func didEndEditing(cell: DailyDataCollectionViewCell, at date: Date, note: String)
}

protocol DailyCollectionViewDataSource: class, DateBoundaries {
    var dayCount: Int { get }
    
    func dailyView(_ dailyView: DailyCollectionView, cellForItemAt indexPath: IndexPath) -> DailyCollectionViewCell
}

/// The object which responds to Daily Collection View's scrolling notifications.
protocol DailyCollectionViewScrollDelegate: class {
    func dailyView(_ dailyView: DailyCollectionView, didScrollToItemAt date: Date)
    func dailyView(_ dailyView: DailyCollectionView, willScrollToItemAt date: Date)
}
