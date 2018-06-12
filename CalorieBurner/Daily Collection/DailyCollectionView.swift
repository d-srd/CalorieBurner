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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dailyDataSource?.dailyView(self, cellForItemAt: indexPath) else {
            fatalError("something went wrong while making a cell")
        }
        
        // ugly as hell
        (cell as? DailyDataCollectionViewCell)?.dailyInputView.delegate = self
        
        return cell
    }
}

extension DailyCollectionView: UICollectionViewDelegateFlowLayout {
    
    // MARK: - Scroll View Delegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let dailyView = scrollView as? DailyCollectionView,
              let visibleCell = dailyView.visibleCells.first as? DailyCollectionViewCell,
              let indexPath = dailyView.indexPath(for: visibleCell),
              let date = dailyView.indexPathProvider?.date(for: indexPath)
        else { return }
        
        dailyScrollDelegate?.dailyView?(self, didScrollToItemAt: date)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // detect scroll direction and send the appropriate delegate messages
        
        // scrolling to the left
        if velocity.x < 0 {
            guard let dailyView = scrollView as? DailyCollectionView,
                  let visibleCellIndexPath = dailyView.visibleCells.compactMap(dailyView.indexPath).first,
                  let date = dailyView.indexPathProvider?.date(for: visibleCellIndexPath)
            else { return }
            
            dailyScrollDelegate?.dailyView?(self, willScrollToItemAt: date)
        }
            
        // scrolling to the right
        else {
            guard let dailyView = scrollView as? DailyCollectionView,
                  let visibleCellIndexPath = dailyView.visibleCells.compactMap(dailyView.indexPath).last,
                  let date = dailyView.indexPathProvider?.date(for: visibleCellIndexPath)
            else { return }
            
            dailyScrollDelegate?.dailyView?(self, willScrollToItemAt: date)
        }
        
        guard keyboardDismissMode == .onDrag else { return }
    }
    
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let itemWidth = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width
        let contentWidth = collectionView.bounds.width
        
        return (contentWidth - itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.bounds.height / 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let itemSize = itemSize else { fatalError("itemSize not implemented") }
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let dailyView = collectionView as? DailyCollectionView,
              let cell = cell as? DailyDataCollectionViewCell
        else { return }
        
        dailyView.dailyDelegate?.dailyView(self, willDisplay: cell, forItemAt: indexPath)
    }
    
    // add an initial section inset such that the first and last cells are centered on screen
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let itemWidth = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width
        let contentWidth = collectionView.bounds.width
        let inset = (contentWidth - itemWidth) / 2
        
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

extension DailyCollectionView: DailyInputViewDelegate {
    // TODO: - less superviews
    func didEndEditing(_ view: DailyInputView, mass: Mass?) {
        guard let cell = view.superview?.superview as? DailyDataCollectionViewCell,
              let indexPath = self.indexPath(for: cell),
              let date = indexPathProvider?.date(for: indexPath),
              let mass = mass
        else { return }
        
        dailyDelegate?.didEndEditing(cell: cell, at: date, mass: mass)
    }
    
    func didEndEditing(_ view: DailyInputView, energy: Energy?) {
        guard let cell = view.superview?.superview as? DailyDataCollectionViewCell,
              let indexPath = self.indexPath(for: cell),
              let date = indexPathProvider?.date(for: indexPath),
              let energy = energy
        else { return }
        
        dailyDelegate?.didEndEditing(cell: cell, at: date, energy: energy)
    }
    
    func didEndEditing(_ view: DailyInputView, mood: Feelings?) {
        guard let cell = view.superview?.superview as? DailyDataCollectionViewCell,
              let indexPath = self.indexPath(for: cell),
              let date = indexPathProvider?.date(for: indexPath),
              let mood = mood
        else { return }
        
        dailyDelegate?.didEndEditing(cell: cell, at: date, mood: mood)
    }
}
