//
//  GradientView.swift
//  CocoaControls
//
//  Created by Dino Srdoč on 21/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

@IBDesignable
open class GradientView: UIView {
    @IBInspectable
    public var startColor: UIColor = .white {
        didSet {
            gradientLayer.colors = [startColor, endColor]
        }
    }
    
    @IBInspectable
    public var endColor: UIColor = .black {
        didSet {
            gradientLayer.colors = [startColor, endColor]
        }
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        return layer as! CAGradientLayer
    }()
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
