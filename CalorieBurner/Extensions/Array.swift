//
//  Array.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 15/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import Foundation

extension Array {
    /// see Array.rotatedRight(by:)
    mutating func rotateRight(by amount: IndexDistance) {
        let rotations = amount % count + count
        
        guard count > 1, rotations != 0 else { return }
        
        let leftSide = Array(self[0 ..< rotations])
        let rightSide = Array(self[rotations ..< count])
        
        self = rightSide + leftSide
    }
    
    /// Move each element of the array `amount` spaces to the right, wrapping.
    /// examples:
    ///
    ///     ["c", "d", "a", "b"] == ["a", "b", "c", "d"].rotatedRight(by: 2)
    ///     // true
    ///
    ///     [1, 2, 3, 4, 5] == [1, 2, 3, 4, 5].rotatedRight(by: 25)
    ///     // true
    func rotatedRight(by amount: IndexDistance) -> [Element] {
        let rotations = (amount % count + count) % count
        
        guard count > 1, rotations != 0 else { return self }
        
        let leftSide = Array(self[0 ..< rotations])
        let rightSide = Array(self[rotations ..< count])
        
        return rightSide + leftSide
    }
}
