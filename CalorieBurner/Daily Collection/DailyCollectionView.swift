//
//  DailyCollectionView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 31/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

private extension UIEdgeInsets {
    var horizontal: CGFloat {
        return self.left + self.right
    }
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
        collectionViewLayout.invalidateLayout()
    }
}

extension DailyCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = dailyDataSource?.dayCount else {
            fatalError("number of days invalid")
        }
        
        return count
    }
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        guard let count = dailyDataSource?.dayCount else {
//            fatalError("number of days invalid")
//        }
//        
//        return count
//    }
    
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let itemWidth = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width
        let contentWidth = collectionView.bounds.width

        return (contentWidth - itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let dailyView = scrollView as? DailyCollectionView,
              let visibleCell = dailyView.visibleCells.first as? DailyCollectionViewCell,
              let indexPath = dailyView.indexPath(for: visibleCell),
              let date = dailyView.indexPathProvider?.date(for: indexPath)
        else { return }
        
        let itemType: DailyItemType = visibleCell.massTextField.isEditing ? .mass : .energy
        
        dailyDelegate?.willCancelEditing(cell: visibleCell, at: date, for: itemType)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let dailyView = scrollView as? DailyCollectionView,
              let visibleCell = dailyView.visibleCells.first as? DailyCollectionViewCell,
              let indexPath = dailyView.indexPath(for: visibleCell),
              let date = dailyView.indexPathProvider?.date(for: indexPath)
        else { return }
        
        dailyScrollDelegate?.dailyView(self, didScrollToItemAt: date)
        dailyDelegate?.didCancelEditing(cell: visibleCell, at: date, for: .mass)

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
        
//        targetContentOffset.pointee = scrollView.contentOffset
//        var factor: CGFloat = 0.5
//        if velocity.x < 0 {
//            factor = -factor
//        }
//        
//        let indexPath = IndexPath(row: 0, section: Int((scrollView.contentOffset.x/itemSize!.width + factor).rounded()))
//        (scrollView as! UICollectionView).scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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
        let itemWidth = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width
        let contentWidth = collectionView.bounds.width
        let inset = (contentWidth - itemWidth) / 2
        
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
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
