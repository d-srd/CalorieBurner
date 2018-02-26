//
//  Daily.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 25/02/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import CoreData

/// Representation of a single day containing a mass and an energy
class Daily: NSManagedObject {
    public class func makeFetchRequest() -> NSFetchRequest<Daily> {
        return NSFetchRequest<Daily>(entityName: "Daily")
    }
}
