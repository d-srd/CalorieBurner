//
//  DailyCollectionView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 31/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

protocol DailyIndexPathProvider: class {
    func indexPath(for date: Date) -> IndexPath?
    func date(for indexPath: IndexPath) -> Date?
}

protocol DailyCollectionViewDelegate: class {
    func dailyView(_ dailyView: DailyCollectionView, didScrollToItemAt date: Date)
    func dailyView(_ dailyView: DailyCollectionView, willScrollToItemAt date: Date)
    func doesItemExist(at date: Date) -> Bool
    
    func willCancelEditing(cell: DailyCollectionViewCell, at indexPath: IndexPath, for item: DailyItemType)
    func didCancelEditing(cell: DailyCollectionViewCell, at indexPath: IndexPath, for item: DailyItemType)
    func didEndEditing(cell: DailyCollectionViewCell, at indexPath: IndexPath, mass: Mass)
    func didEndEditing(cell: DailyCollectionViewCell, at indexPath: IndexPath, energy: Energy)
}

protocol DailyCollectionViewDataSource: class {
    var startDate: Date { get }
    var endDate: Date { get }
    var dayCount: Int { get }
    
    func dailyView(_ dailyView: DailyCollectionView, cellForItemAt date: Date) -> DailyCollectionViewCell
}

class DailyCollectionView: UICollectionView {
    weak var dailyDelegate: DailyCollectionViewDelegate?
    weak var dailyDataSource: DailyCollectionViewDataSource?
    
    weak var indexPathProvider: DailyIndexPathProvider?
    
    func scrollToItem(at date: Date, at scrollPosition: UICollectionViewScrollPosition, animated: Bool) {
        guard let indexPath = indexPathProvider?.indexPath(for: date) else {
            return
        }
        
        scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        super.dataSource = self
        super.delegate = self
    }
}

extension DailyCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let count = dailyDataSource?.dayCount else {
            fatalError("number of days invalid")
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let date = indexPathProvider?.date(for: indexPath),
              let cell = dailyDataSource?.dailyView(self, cellForItemAt: date)
        else {
                fatalError("something went wrong while making a cell")
        }
        
        cell.cellDelegate = self
        
        return cell
    }
}

extension DailyCollectionView: UICollectionViewDelegateFlowLayout {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let dailyView = scrollView as? DailyCollectionView,
              let visibleCellIndexPath = dailyView.visibleCells.compactMap(dailyView.indexPath).first,
              let date = dailyView.indexPathProvider?.date(for: visibleCellIndexPath)
        else { return }
        
        dailyDelegate?.dailyView(self, didScrollToItemAt: date)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x < 0 {
            guard let dailyView = scrollView as? DailyCollectionView,
                  let visibleCellIndexPath = dailyView.visibleCells.compactMap(dailyView.indexPath).first,
                  let date = dailyView.indexPathProvider?.date(for: visibleCellIndexPath)
            else { return }
            
            dailyDelegate?.dailyView(self, willScrollToItemAt: date)
        } else {
            guard let dailyView = scrollView as? DailyCollectionView,
                  let visibleCellIndexPath = dailyView.visibleCells.compactMap(dailyView.indexPath).last,
                  let date = dailyView.indexPathProvider?.date(for: visibleCellIndexPath)
            else { return }
            
            dailyDelegate?.dailyView(self, willScrollToItemAt: date)
        }
    }
}

extension DailyCollectionView: DailyCellDelegate {
    func willCancelEditing(cell: DailyCollectionViewCell, for itemType: DailyItemType) {
        guard let indexPath = self.indexPath(for: cell) else { return }
        
        dailyDelegate?.willCancelEditing(cell: cell, at: indexPath, for: itemType)
    }
    
    func didCancelEditing(cell: DailyCollectionViewCell, for itemType: DailyItemType) {
        guard let indexPath = self.indexPath(for: cell) else { return }

        dailyDelegate?.didCancelEditing(cell: cell, at: indexPath, for: itemType)
    }
    
    func didEndEditing(cell: DailyCollectionViewCell, mass: Measurement<UnitMass>) {
        guard let indexPath = self.indexPath(for: cell) else { return }

        dailyDelegate?.didEndEditing(cell: cell, at: indexPath, mass: mass)
    }
    
    func didEndEditing(cell: DailyCollectionViewCell, energy: Measurement<UnitEnergy>) {
        guard let indexPath = self.indexPath(for: cell) else { return }

        dailyDelegate?.didEndEditing(cell: cell, at: indexPath, energy: energy)
    }
}
