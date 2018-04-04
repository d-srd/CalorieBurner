//
//  DailyCollectionView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 11/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

extension DailyFetchedResultsController: DailyIndexPathProvider { }

class DailyCollectionViewController: UIViewController {
    @IBOutlet weak var dailyView: DailyCollectionView!
    
    private lazy var viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let startDate = Calendar.current.date(from: DateComponents(year: 2000, month: 01, day: 01))!
    let endDate = Calendar.current.date(from: DateComponents(year: 2030, month: 12, day: 31))!
    lazy var dayCount = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day!
    
    var itemSize: (() -> CGSize)?
    private let defaultItemSize = CGSize(width: 200, height: 88)
    
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
        
        dailyView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    func doesItemExist(at date: Date) -> Bool {
        guard let indexPath = dailyView.indexPathProvider?.indexPath(for: date),
              fetchedResultsController.object(at: indexPath) != nil
        else { return false }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dailyView.dailyDelegate = self
        dailyView.dailyDataSource = self
        dailyView.indexPathProvider = fetchedResultsController
        
        try? fetchedResultsController.performFetch()
        
        dailyView.reloadData()
    }
}

extension DailyCollectionViewController: DailyCollectionViewDataSource {
    func dailyView(_ dailyView: DailyCollectionView, cellForItemAt indexPath: IndexPath) -> DailyCollectionViewCell {
        guard let cell = dailyView.dequeueReusableCell(withReuseIdentifier: "DailyCell", for: indexPath) as? DailyCollectionViewCell else {
            fatalError("oopsie doopsie dequeeopsie")
        }
        
        cell.massPickerView = DailyMassPickerView()
        cell.energyPickerView = DailyEnergyPickerView()
        cell.massPickerToolbar = DailyMassPickerToolbar()
        cell.energyPickerToolbar = DailyEnergyPickerToolbar()
        
        return cell
    }
}

extension DailyCollectionViewController: DailyCollectionViewDelegate {
    func dailyView(_ dailyView: DailyCollectionView, willDisplay cell: DailyCollectionViewCell, forItemAt indexPath: IndexPath) {
        if let object = fetchedResultsController.object(at: indexPath) {
            cell.mass = object.mass?.converted(to: UserDefaults.standard.mass)
            cell.energy = object.energy?.converted(to: UserDefaults.standard.energy)
        } else {
            cell.setEmpty()
        }
    }
    
    
    func dailyView(_ dailyView: DailyCollectionView, sizeForItemAt date: Date) -> CGSize {
        return dailyView.itemSize ?? itemSize?() ?? defaultItemSize
    }
    
    func willCancelEditing(cell: DailyCollectionViewCell, at date: Date, for itemType: DailyItemType) {
        isCancellingEditing = true
    }
    
    func didCancelEditing(cell: DailyCollectionViewCell, at date: Date, for itemType: DailyItemType) {
        isCancellingEditing = false
    }
    
    func didEndEditing(cell: DailyCollectionViewCell, at date: Date, mass: Mass) {
        do {
            _ = try CoreDataStack.shared.updateOrCreate(at: date, mass: mass, energy: nil)
        } catch {
            print("error updating cell: ", error)
        }
    }
    
    func didEndEditing(cell: DailyCollectionViewCell, at date: Date, energy: Energy) {
        do {
            _ = try CoreDataStack.shared.updateOrCreate(at: date, mass: nil, energy: energy)
        } catch {
            print("error updating cell: ", error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DailyCollectionViewCell else { return }
        
        if let object = fetchedResultsController.object(at: indexPath) {
            cell.mass = object.mass?.converted(to: UserDefaults.standard.mass)
            cell.energy = object.energy?.converted(to: UserDefaults.standard.energy)
        } else {
            cell.setEmpty()
        }
    }
}
