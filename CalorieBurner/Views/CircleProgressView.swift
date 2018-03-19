//
//  ProgressView.swift
//  CalorieBurner
//
//  Created by Dino Srdoč on 19/03/2018.
//  Copyright © 2018 Dino Srdoč. All rights reserved.
//

import UIKit

@IBDesignable
class CircleProgressView: UIView {
    
    @IBInspectable
    var width: CGFloat = 4 {
        didSet {
            progressLayer.width = width
        }
    }
    
    @IBInspectable
    var outerColor: UIColor = .gray {
        didSet {
            progressLayer.outerColor = outerColor.cgColor
        }
    }
    
    @IBInspectable
    var innerColor: UIColor = .orange {
        didSet {
            progressLayer.innerColor = innerColor.cgColor
        }
    }
    
    @IBInspectable
    public dynamic var progress: CGFloat = 0.5 {
        didSet {
            progressLayer.progress = progress
        }
    }
    
    private var progressLayer: CircleProgressLayer {
        return layer as! CircleProgressLayer
    }
    
    override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        if event == #keyPath(CircleProgressLayer.progress),
            let action = action(for: layer, forKey: #keyPath(backgroundColor)) as? CAAnimation
        {
            let animation = CABasicAnimation(keyPath: #keyPath(CircleProgressLayer.progress))
//            animation.keyPath = #keyPath(CircleProgressLayer.progress)
            animation.fromValue = progressLayer.progress
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
            
            self.layer.add(animation, forKey: #keyPath(CircleProgressLayer.progress))
        }
        
        return super.action(for: layer, forKey: event)
    }
    
    override class var layerClass: AnyClass {
        return CircleProgressLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shouldRasterize = true
        layer.contentsScale = UIScreen.main.scale
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.shouldRasterize = true
        layer.contentsScale = UIScreen.main.scale
        layer.rasterizationScale = UIScreen.main.scale
    }
}

class CircleProgressLayer: CALayer {
    private let startAngle = 3 * CGFloat.pi / 2
    
    @NSManaged var progress: CGFloat
    var outerColor: CGColor = UIColor.gray.cgColor
    var innerColor: CGColor = UIColor.orange.cgColor
    var width: CGFloat = 10
    
    private lazy var backgroundPath: UIBezierPath = {
        let path = UIBezierPath(
            arcCenter: bounds.midPoint,
            radius: min(bounds.width / 2, bounds.height / 2) - width / 2,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        )
        
        return path
    }()
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(progress) {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        UIGraphicsPushContext(ctx)
        
        ctx.setStrokeColor(outerColor)
        backgroundPath.lineWidth = width
        backgroundPath.stroke()
        
        let endAngle: CGFloat
        
        switch progress {
        case ...0:
            endAngle = startAngle
        case 0..<1:
            endAngle = (2 * CGFloat.pi * progress) - CGFloat.pi / 2
        case 1...:
            endAngle = 2 * CGFloat.pi + startAngle
        default:
            fatalError("wtf bro")
        }
        
        ctx.setStrokeColor(innerColor)
        let innerPath = UIBezierPath(
            arcCenter: bounds.midPoint,
            radius: min(bounds.width / 2, bounds.height / 2) - width / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        innerPath.lineCapStyle = .round
        innerPath.lineWidth = width
        innerPath.stroke()
        
        UIGraphicsPopContext()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("required init?(coder:) not implemented")
    }
    
    override init() {
        super.init()
    }
    
    // this is only called when a layer already exists, to make a "shadow copy"
    override init(layer: Any) {
        if let layer = layer as? CircleProgressLayer {
            outerColor = layer.outerColor
            innerColor = layer.innerColor
            width = layer.width
        }
        super.init(layer: layer)
    }
}
