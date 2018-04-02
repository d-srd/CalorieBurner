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

protocol DailyCollectionViewDelegate: class {
    func dailyView(_ dailyView: DailyCollectionView, willDisplay cell: DailyCollectionViewCell, forItemAt indexPath: IndexPath)
    
    func willCancelEditing(cell: DailyCollectionViewCell, at date: Date, for itemType: DailyItemType)
    func didCancelEditing(cell: DailyCollectionViewCell, at date: Date, for itemType: DailyItemType)
    func didEndEditing(cell: DailyCollectionViewCell, at date: Date, mass: Mass)
    func didEndEditing(cell: DailyCollectionViewCell, at date: Date, energy: Energy)
}

protocol DailyCollectionViewDataSource: class, DateBoundaries {
    var dayCount: Int { get }
    
    func dailyView(_ dailyView: DailyCollectionView, cellForItemAt indexPath: IndexPath) -> DailyCollectionViewCell
}

protocol DailyCollectionViewScrollDelegate: class {
    func dailyView(_ dailyView: DailyCollectionView, didScrollToItemAt date: Date)
    func dailyView(_ dailyView: DailyCollectionView, willScrollToItemAt date: Date)
}
