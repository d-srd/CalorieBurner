//
//  DailyCollectionView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 11/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

extension DailyFetchedResultsController: DailyIndexPathProvider { }

/// View Controller preconfigured for displaying a Daily Collection View
class DailyCollectionViewController: UIViewController {
    @IBOutlet weak var dailyView: DailyCollectionView!
    
    private lazy var viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let startDate = Calendar.current.date(from: DateComponents(year: 2000, month: 01, day: 01))!
    let endDate = Calendar.current.date(from: DateComponents(year: 2030, month: 12, day: 31))!
    lazy var dayCount = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day!
    
    private let defaultItemSize = CGSize(width: 200, height: 88)
    
    private lazy var fetchedResultsController: DailyFetchedResultsController = {
        // fetch all items in ascending date order
        let request = Daily.tableFetchRequest()
        let controller = DailyFetchedResultsController(fetchRequest: request,
                                                       managedObjectContext: viewContext,
                                                       dateBounds: (startDate, endDate))
        return controller
    }()
        
    func scrollToItem(at date: Date, animated: Bool) {
        guard let indexPath = fetchedResultsController.indexPath(for: date) else { return }
        
        dailyView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    func doesItemExist(at date: Date) -> Bool {
        guard let indexPath = dailyView.indexPathProvider?.indexPath(for: date),
              fetchedResultsController.object(at: indexPath) != nil
        else { return false }
        
        return true
    }
    
    func reloadData() {
        dailyView.reloadData()
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
        if let object = fetchedResultsController.object(at: indexPath) {
            let cell = dailyView.dequeueReusableCell(withReuseIdentifier: "DailyCell", for: indexPath) as! DailyDataCollectionViewCell
            cell.configure(mass: object.mass?.converted(to: UserDefaults.standard.mass),
                           energy: object.energy?.converted(to: UserDefaults.standard.energy),
                           mood: object.mood)
            
            return cell
        }
        
        let cell = dailyView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath) as! DailyCollectionViewCell
        return cell
    }
}

extension DailyCollectionViewController: DailyCollectionViewDelegate {
    func dailyView(_ dailyView: DailyCollectionView, willDisplay cell: DailyCollectionViewCell, forItemAt indexPath: IndexPath) {
        collectionView(dailyView, willDisplay: cell, forItemAt: indexPath)
    }
    
    
    func dailyView(_ dailyView: DailyCollectionView, sizeForItemAt date: Date) -> CGSize {
        return dailyView.itemSize ?? defaultItemSize
    }
    
    func didEndEditing(cell: DailyDataCollectionViewCell, at date: Date, mass: Mass) {
        do {
            _ = try CoreDataStack.shared.updateOrCreate(at: date, mass: mass, energy: nil, mood: nil)
        } catch {
            print("error updating cell: ", error)
        }
    }
    
    func didEndEditing(cell: DailyDataCollectionViewCell, at date: Date, energy: Energy) {
        do {
            _ = try CoreDataStack.shared.updateOrCreate(at: date, mass: nil, energy: energy, mood: nil)
        } catch {
            print("error updating cell: ", error)
        }
    }
    
    func didEndEditing(cell: DailyDataCollectionViewCell, at date: Date, mood: Feelings) {
        do {
            _ = try CoreDataStack.shared.updateOrCreate(at: date, mass: nil, energy: nil, mood: mood)
        } catch {
            print("error updating cell: ", error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DailyDataCollectionViewCell,
              let object = fetchedResultsController.object(at: indexPath)
        else { return }
        
        cell.configure(mass: object.mass?.converted(to: UserDefaults.standard.mass),
                       energy: object.energy?.converted(to: UserDefaults.standard.energy),
                       mood: object.mood)
    }
}
