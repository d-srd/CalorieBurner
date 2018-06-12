//
//  FirstResponder.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 25/04/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

// Resource: https://stackoverflow.com/a/27140764/9515505

extension UIResponder {
    private weak static var _currentFirstResponder: UIResponder? = nil
    
    public static var current: UIResponder? {
        UIResponder._currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(sender:)), to: nil, from: nil, for: nil)
        return UIResponder._currentFirstResponder
    }
    
    @objc internal func findFirstResponder(sender: AnyObject) {
        UIResponder._currentFirstResponder = self
    }
}
