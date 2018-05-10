//
//  CGRect.swift
//  CocoaControls
//
//  Created by Dino Srdoč on 21/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

extension CGRect {
    var midPoint: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}
