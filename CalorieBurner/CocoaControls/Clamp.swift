//
//  Clamp.swift
//  CocoaControls
//
//  Created by Dino Srdoč on 21/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation

public func clamp<T: Comparable>(_ item: T, low: T, high: T) -> T {
    return max(low, min(item, high))
}
