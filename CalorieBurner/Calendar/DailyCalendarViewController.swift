//
//  File.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 18/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DailyCalendarViewCell: DayViewCell {
    @IBOutlet weak var existingItemView: UIView!
}

class DailyCalendarViewController: MonthlyCalendarViewController {
    @IBOutlet weak var dailyCollectionView: UICollectionView!
    
    private let cellWidth: CGFloat = 320
    private let cellHeight: CGFloat = 120
    
    private lazy var viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private lazy var dayCount = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day!
    private(set) var isCancellingEditing = false
    
    func scrollToItem(at date: Date, animated: Bool) {
        guard let indexPath = fetchedResultsController.indexPath(for: date) else {
            return
        }
        
        dailyCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    private lazy var fetchedResultsController: DailyFetchedResultsController = {
        let request = Daily.tableFetchRequest()
        let controller = DailyFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            dateBounds: (startDate, endDate)
        )
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dailyCollectionView.delegate = self
        dailyCollectionView.dataSource = self
        
        try? fetchedResultsController.performFetch()
        
        dailyCollectionView.reloadData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: .UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: .UIKeyboardWillHide,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {

        // ugliest line of code I've written in this entire project
        guard let _keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double,
              self.view.frame.origin.y == 0
        else { return }

        let keyboardSize = view.convert(_keyboardSize, from: view.window)

        UIView.animate(withDuration: keyboardAnimationDuration) {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard self.view.frame.origin.y != 0 else { return }
        
        // this is the most genius line of code. ever.
        guard let cell = dailyCollectionView.visibleCells.first as? DailyCollectionViewCell,
              isCancellingEditing || !cell.massTextField.isEditing,
              let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        UIView.animate(withDuration: keyboardAnimationDuration) {
            self.view.frame.origin.y = 0
        }
    }
    
    override func configure(cell: DayViewCell?, cellState: CellState) {
        super.configure(cell: cell, cellState: cellState)
    }
    
    override func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        super.calendar(calendar, didSelectDate: date, cell: cell, cellState: cellState)
        
        scrollToItem(at: date, animated: true)
    }
    
    private func dailyDidScroll(toDate date: Date) {
        calendarView.scrollToDate(date)
        calendarView.deselectAllDates()
        calendarView.selectDates([date])
    }
}

extension DailyCalendarViewController: UICollectionViewDataSource {
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

extension DailyCalendarViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let dailyView = scrollView as? UICollectionView,
            let currentCellIndexPath = dailyView.indexPathsForVisibleItems.first,
            let date = fetchedResultsController.date(for: currentCellIndexPath)
            else { return }
        
//        delegate?.dailyView(dailyView, didScrollToItemAt: date)
        
        dailyDidScroll(toDate: date)
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
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    //        return 120
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
        //        return self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: section).left * 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //        return .zero
        
        //        let sideInset = (collectionView.frame.size.width - cellWidth) / 2
        //        return UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout
            //              let dataSourceCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section),
            //              dataSourceCount > 0
            else { return .zero }
        
        // only 1 cell per section
        //        assert(collectionView.numberOfItems(inSection: section) <= 1, "More than one item in section")
        let cellCount: CGFloat = 1
        let itemSpacing = layout.minimumInteritemSpacing
        let widthOfCell = cellWidth + itemSpacing
        var insets = layout.sectionInset
        
        let totalCellWidth = (widthOfCell * cellCount) - itemSpacing
        let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
        
        //        guard totalCellWidth < contentWidth else {
        //            return insets
        //        }
        
        let padding = (contentWidth - totalCellWidth) / 2
                insets.top = padding / 2
        insets.left = padding
        insets.right = padding
        
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension DailyCalendarViewController: DailyCellDelegate {
    func willCancelEditing(cell: DailyCollectionViewCell, for itemType: DailyItemType) {
        isCancellingEditing = true
    }
    
    func didCancelEditing(cell: DailyCollectionViewCell, for item: DailyItemType) {
        isCancellingEditing = false
    }
    
    func didEndEditing(cell: DailyCollectionViewCell, mass: Measurement<UnitMass>) {
        guard let indexPath = dailyCollectionView.indexPath(for: cell),
            let date = fetchedResultsController.date(for: indexPath)
            else { return }
        
        do {
            try CoreDataStack.shared.updateOrCreate(at: date, mass: mass, energy: nil)
        } catch {
            print((error as NSError).localizedDescription)
        }
    }
    
    func didEndEditing(cell: DailyCollectionViewCell, energy: Measurement<UnitEnergy>) {
        guard let indexPath = dailyCollectionView.indexPath(for: cell),
            let date = fetchedResultsController.date(for: indexPath)
            else { return }
        
        do {
            try CoreDataStack.shared.updateOrCreate(at: date, mass: nil, energy: energy)
        } catch {
            print((error as NSError).localizedDescription)
        }
    }
    
    
}
