//
//  ProgressView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 19/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

extension CGSize {
    init(length: CGFloat) {
        self.init(width: length, height: length)
    }
}

extension CGPoint {
    mutating func add(_ value: CGFloat) {
        self.x += value
        self.y += value
    }
    
    func adding(_ value: CGFloat) -> CGPoint {
        return CGPoint(x: x + value, y: y + value)
    }
    
    mutating func subtract(_ value: CGFloat) {
        self.x -= value
        self.y -= value
    }
    
    func subtracting(_ value: CGFloat) -> CGPoint {
        return CGPoint(x: x - value, y: y - value)
    }
}

public protocol CircleProgressViewDelegate: class {
    func circle(_ circle: CircleProgressView, didUpdateProgress value: CGFloat)
    func circle(_ circle: CircleProgressView, willUpdateProgress value: CGFloat)
}

@IBDesignable
public class CircleProgressView: UIView {
    
    weak var delegate: CircleProgressViewDelegate?
    
    @IBInspectable
    public var width: CGFloat = 4 {
        didSet {
            progressLayer.path = circlePath.cgPath
            backgroundLayer.path = circlePath.cgPath
            
            progressLayer.lineWidth = width
            backgroundLayer.lineWidth = width
        }
    }
    
    @IBInspectable
    public var outerColor: UIColor = .gray {
        didSet {
            backgroundLayer.strokeColor = outerColor.cgColor
        }
    }
    
    @IBInspectable
    public var innerColor: UIColor = .orange {
        didSet {
            progressLayer.strokeColor = innerColor.cgColor
        }
    }
    
    @IBInspectable
    public var displaysPercentage: Bool = false {
        didSet {
            if displaysPercentage {
                addSubview(percentageLabel)
            } else {
                percentageLabel.removeFromSuperview()
            }
        }
    }
    
    @IBInspectable
    public dynamic var progress: CGFloat {
        get {
            return progressLayer.strokeEnd
        }
        set {
            delegate?.circle(self, willUpdateProgress: progress)
            
            let boundedProgress = clamp(newValue, low: 0, high: 1)
            progressLayer.strokeEnd = boundedProgress
            percentageLabel.text = percentageFormatter.string(from: boundedProgress as NSNumber)
            
            delegate?.circle(self, didUpdateProgress: boundedProgress)
        }
    }
    
    private let percentageFormatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.numberStyle = .percent
        
        return fmt
    }()
    
    private lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = bounds
        layer.path = circlePath.cgPath
        layer.strokeColor = outerColor.cgColor
        layer.fillColor = nil
        layer.lineCap = kCALineCapRound
        
        return layer
    }()
    
    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = bounds
        layer.path = circlePath.cgPath
        layer.strokeColor = innerColor.cgColor
        layer.fillColor = nil
        layer.lineCap = kCALineCapRound
        
        return layer
    }()
    
    private var radius: CGFloat {
        return min(bounds.width, bounds.height) / 2 - width / 2
    }
    
    private lazy var percentageLabel: UILabel = {
        let offset = radius / 2
        let frame = CGRect(
            origin: bounds.midPoint.subtracting(offset),
            size: CGSize(length: offset * 2)
        )
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.text = percentageFormatter.string(from: progress as NSNumber)
        
        return label
    }()
    
    private var circlePath: UIBezierPath {
        return UIBezierPath(
            arcCenter: bounds.midPoint,
            radius: radius,
            startAngle: 3 * .pi / 2,
            endAngle: 3 * .pi / 2 + 2 * .pi,
            clockwise: true
        )
    }
    
    override open func action(for layer: CALayer, forKey event: String) -> CAAction? {
        if event == #keyPath(progress),
            let action = action(for: layer, forKey: #keyPath(backgroundColor)) as? CAAnimation
        {
            let animation = CABasicAnimation(keyPath: #keyPath(progress))
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = progress
            animation.beginTime = action.beginTime
            animation.duration = action.duration
            animation.speed = action.speed
            animation.timeOffset = action.timeOffset
            animation.repeatCount = action.repeatCount
            animation.repeatDuration = action.repeatDuration
            animation.autoreverses = action.autoreverses
            animation.fillMode = action.fillMode
            animation.timingFunction = action.timingFunction
            animation.delegate = action.delegate
            
            self.layer.add(animation, forKey: #keyPath(progress))
        }
        
        return super.action(for: layer, forKey: event)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        // for those sexy retina curves -- real layers have curves!
        layer.shouldRasterize = true
        layer.contentsScale = UIScreen.main.scale
        layer.rasterizationScale = UIScreen.main.scale
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        backgroundLayer.frame = bounds
        progressLayer.frame = bounds
    }
}
