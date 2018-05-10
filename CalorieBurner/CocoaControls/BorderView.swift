//
//  BorderView.swift
//  CocoaControls
//
//  Created by Dino Srdoč on 21/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

@IBDesignable
open class BorderView: UIView {
    @IBInspectable
    public var borderRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = borderRadius }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }
    
    @IBInspectable
    public var borderColor: UIColor = .black {
        didSet { layer.borderColor = borderColor.cgColor }
    }
}
