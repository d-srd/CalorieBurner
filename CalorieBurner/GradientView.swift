//
//  GradientView.swift
//  WeeklyBurner
//
//  Created by Dino Srdoč on 29/01/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

// taken from https://stackoverflow.com/a/41684439

import UIKit

extension CGRect {
    var midPoint: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}

@IBDesignable
open class GradientView: UIView {
    @IBInspectable
    public var startColor: UIColor = .white {
        didSet {
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var endColor: UIColor = .white {
        didSet {
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
            setNeedsDisplay()
        }
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        let mid = self.bounds.midPoint
        let height = self.bounds.height
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        return gradientLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

@IBDesignable
open class DesignableView: GradientView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}

@IBDesignable
open class ShadowView: UIView {
    open override var bounds: CGRect {
        didSet {
            makeShadow()
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize = CGSize(width: 0, height: 3) {
        didSet { makeShadow() }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat = 5 {
        didSet { makeShadow() }
    }
    
    @IBInspectable
    var shadowOpacity: Float = 0.3 {
        didSet { makeShadow() }
    }
    
    @IBInspectable
    var shadowColor: UIColor = .black {
        didSet { makeShadow() }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 8 {
        didSet { makeShadow() }
    }
    
    private func makeShadow() {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: .zero).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
