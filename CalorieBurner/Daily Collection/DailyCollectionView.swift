//
//  DailyCollectionView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 11/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

protocol DailyCollectionViewDelegate: class {
    func dailyView(_ dailyView: UICollectionView, didScrollToItemAt date: Date)
}

class DailyCollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: DailyCollectionViewDelegate?
    
    private let cellWidth: CGFloat = 320
    private let cellHeight: CGFloat = 120
    
    private lazy var viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let startDate = Calendar.current.date(from: DateComponents(year: 2000, month: 01, day: 01))!
    private let endDate = Calendar.current.date(from: DateComponents(year: 2030, month: 12, day: 31))!
    private lazy var dayCount = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day!
    
    private(set) var isCancellingEditing = false
    
    private lazy var fetchedResultsController: DailyFetchedResultsController = {
        let request = Daily.tableFetchRequest()
        let controller = DailyFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            dateBounds: (startDate, endDate)
        )
        return controller
    }()
        
    func scrollToItem(at date: Date, animated: Bool) {
        guard let indexPath = fetchedResultsController.indexPath(for: date) else {
            return
        }
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        try? fetchedResultsController.performFetch()
        
        collectionView.reloadData()
    }
}

extension DailyCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCell", for: indexPath) as? DailyCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.cellDelegate = self
        
        cell.massPickerView = DailyMassPickerView()
        cell.energyPickerView = DailyEnergyPickerView()
        cell.massPickerToolbar = DailyMassPickerToolbar()
        cell.energyPickerToolbar = DailyEnergyPickerToolbar()
        
        return cell
    }
}

extension DailyCollectionViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let dailyView = scrollView as? UICollectionView,
            let currentCellIndexPath = dailyView.indexPathsForVisibleItems.first,
            let date = fetchedResultsController.date(for: currentCellIndexPath)
            else { return }
        
        delegate?.dailyView(dailyView, didScrollToItemAt: date)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DailyCollectionViewCell else { return }
        
        if let object = fetchedResultsController.object(at: indexPath) {
            cell.mass = object.mass?.converted(to: UserDefaults.standard.mass ?? .kilograms)
            cell.energy = object.energy?.converted(to: UserDefaults.standard.energy ?? .kilocalories)
        } else {
            cell.setEmpty()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let cellWidth = layout.itemSize.width
        let contentWidth = collectionView.frame.width
        let padding = (contentWidth - cellWidth) / 2
        
        return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
//        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout,
//              let dataSourceCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section),
//              dataSourceCount > 0
//        else { return .zero }
//
//        // only 1 cell per section
//        assert(collectionView.numberOfItems(inSection: section) <= 1, "More than one item in section")
//        let cellCount = CGFloat(dataSourceCount)
//        let itemSpacing = layout.minimumInteritemSpacing
//        let cellWidth = layout.itemSize.width + itemSpacing
//        var insets = layout.sectionInset
//
//        let totalCellWidth = (cellWidth * cellCount) - itemSpacing
//        let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
//
//        guard totalCellWidth < contentWidth else {
//            return insets
//        }
//
//        let padding = (contentWidth - totalCellWidth) / 2
//        insets.left = padding
//        insets.right = padding
//
//        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }

}

extension DailyCollectionViewController: DailyCellDelegate {
    func willCancelEditing(cell: DailyCollectionViewCell, for itemType: DailyItemType) {
        isCancellingEditing = true
    }
    
    func didCancelEditing(cell: DailyCollectionViewCell, for item: DailyItemType) {
        isCancellingEditing = false
    }
    
    func didEndEditing(cell: DailyCollectionViewCell, mass: Measurement<UnitMass>) {
        guard let indexPath = collectionView.indexPath(for: cell),
              let date = fetchedResultsController.date(for: indexPath)
        else { return }
        
        do {
            try CoreDataStack.shared.updateOrCreate(at: date, mass: mass, energy: nil)
        } catch {
            print((error as NSError).localizedDescription)
        }
    }
    
    func didEndEditing(cell: DailyCollectionViewCell, energy: Measurement<UnitEnergy>) {
        guard let indexPath = collectionView.indexPath(for: cell),
            let date = fetchedResultsController.date(for: indexPath)
            else { return }
        
        do {
            try CoreDataStack.shared.updateOrCreate(at: date, mass: nil, energy: energy)
        } catch {
            print((error as NSError).localizedDescription)
        }
    }
    
    
}
