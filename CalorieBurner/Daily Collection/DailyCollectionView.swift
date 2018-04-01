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
//    func dailyView(_ dailyView: DailyCollectionView, sizeForItemAt date: Date) -> CGSize
    func dailyView(_ dailyView: DailyCollectionView, willDisplay cell: DailyCollectionViewCell, forItemAt indexPath: IndexPath)
//    func doesItemExist(at date: Date) -> Bool
    
    func willCancelEditing(cell: DailyCollectionViewCell, at date: Date, for itemType: DailyItemType)
    func didCancelEditing(cell: DailyCollectionViewCell, at date: Date, for itemType: DailyItemType)
    func didEndEditing(cell: DailyCollectionViewCell, at date: Date, mass: Mass)
    func didEndEditing(cell: DailyCollectionViewCell, at date: Date, energy: Energy)
}

protocol DailyCollectionViewDataSource: class {
    var startDate: Date { get }
    var endDate: Date { get }
    var dayCount: Int { get }
    
    func dailyView(_ dailyView: DailyCollectionView, cellForItemAt indexPath: IndexPath) -> DailyCollectionViewCell
}

protocol DailyCollectionViewScrollDelegate: class {
    func dailyView(_ dailyView: DailyCollectionView, didScrollToItemAt date: Date)
    func dailyView(_ dailyView: DailyCollectionView, willScrollToItemAt date: Date)
}

class DailyCollectionView: UICollectionView {
    weak var dailyDelegate: DailyCollectionViewDelegate?
    weak var dailyDataSource: DailyCollectionViewDataSource?
    weak var dailyScrollDelegate: DailyCollectionViewScrollDelegate?
    weak var indexPathProvider: DailyIndexPathProvider?
    
    var itemSize: CGSize? {
        didSet {
            if let size = itemSize {
                (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = size
            }
        }
    }
    
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
        guard let cell = dailyDataSource?.dailyView(self, cellForItemAt: indexPath)
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
        
        dailyScrollDelegate?.dailyView(self, didScrollToItemAt: date)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x < 0 {
            guard let dailyView = scrollView as? DailyCollectionView,
                  let visibleCellIndexPath = dailyView.visibleCells.compactMap(dailyView.indexPath).first,
                  let date = dailyView.indexPathProvider?.date(for: visibleCellIndexPath)
            else { return }
            
            dailyScrollDelegate?.dailyView(self, willScrollToItemAt: date)
            print("scrolling daily view to the left")
        } else {
            guard let dailyView = scrollView as? DailyCollectionView,
                  let visibleCellIndexPath = dailyView.visibleCells.compactMap(dailyView.indexPath).last,
                  let date = dailyView.indexPathProvider?.date(for: visibleCellIndexPath)
            else { return }
            
            dailyScrollDelegate?.dailyView(self, willScrollToItemAt: date)
            print("scrolling daily view to the right")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let itemSize = itemSize else { fatalError("itemSize not implemented") }
        return itemSize
//        guard itemSize == nil else { return itemSize! }
//
//        guard let dailyView = collectionView as? DailyCollectionView,
//              let date = dailyView.indexPathProvider?.date(for: indexPath),
//              let size = dailyView.dailyDelegate?.dailyView(dailyView, sizeForItemAt: date)
//        else { fatalError("Size for item not implemented") }
//
//        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let dailyView = collectionView as? DailyCollectionView,
              let cell = cell as? DailyCollectionViewCell
        else { return }
        
        dailyView.dailyDelegate?.dailyView(self, willDisplay: cell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let dailyView = collectionView as? DailyCollectionView,
              let layout = collectionViewLayout as? UICollectionViewFlowLayout,
              let dataSourceCount = dailyView.dataSource?.collectionView(dailyView, numberOfItemsInSection: section),
              dataSourceCount == 1,
              let itemSize = itemSize
        else { return .zero }

        let itemSpacing = layout.minimumInteritemSpacing
        let cellWidth = itemSize.width + itemSpacing
        let cellCount = CGFloat(dailyView.numberOfSections(in: dailyView))
        var insets = layout.sectionInset

        let totalCellWidth = cellWidth - itemSpacing
        let contentWidth = dailyView.frame.size.width -
            dailyView.contentInset.left -
            dailyView.contentInset.right

        guard totalCellWidth < contentWidth else { return insets }

        let padding = (contentWidth - totalCellWidth) / 2
        insets.left = padding
        insets.right = padding

        return insets
    }
}

extension DailyCollectionView: DailyCellDelegate {
    func willCancelEditing(cell: DailyCollectionViewCell, for itemType: DailyItemType) {
        guard let indexPath = self.indexPath(for: cell),
              let date = indexPathProvider?.date(for: indexPath)
        else { return }
        
        dailyDelegate?.willCancelEditing(cell: cell, at: date, for: itemType)
    }
    
    func didCancelEditing(cell: DailyCollectionViewCell, for itemType: DailyItemType) {
        guard let indexPath = self.indexPath(for: cell),
              let date = indexPathProvider?.date(for: indexPath)
        else { return }
        
        dailyDelegate?.didCancelEditing(cell: cell, at: date, for: itemType)
    }
    
    func didEndEditing(cell: DailyCollectionViewCell, mass: Measurement<UnitMass>) {
        guard let indexPath = self.indexPath(for: cell),
              let date = indexPathProvider?.date(for: indexPath)
        else { return }
        
        dailyDelegate?.didEndEditing(cell: cell, at: date, mass: mass)
    }
    
    func didEndEditing(cell: DailyCollectionViewCell, energy: Measurement<UnitEnergy>) {
        guard let indexPath = self.indexPath(for: cell),
              let date = indexPathProvider?.date(for: indexPath)
        else { return }
        
        dailyDelegate?.didEndEditing(cell: cell, at: date, energy: energy)
    }
}
