//
//  ShadowView.swift
//  CocoaControls
//
//  Created by Dino Srdoč on 21/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

@IBDesignable
public class ShadowView: UIView {
    @IBInspectable
    public var shadowOffset: CGSize = .zero {
        didSet { layer.shadowOffset = shadowOffset }
    }
    
    @IBInspectable
    public var shadowRadius: CGFloat = 0 {
        didSet { layer.shadowRadius = shadowRadius }
    }
    
    @IBInspectable
    public var shadowOpacity: Float = 1 {
        didSet { layer.shadowOpacity = shadowOpacity }
    }
    
    @IBInspectable
    public var shadowColor: UIColor = .black {
        didSet { layer.shadowColor = shadowColor.cgColor }
    }
    
    @IBInspectable
    public var borderRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = borderRadius }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.contentsScale = UIScreen.main.scale
        layer.masksToBounds = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.contentsScale = UIScreen.main.scale
        layer.masksToBounds = false
    }
}
