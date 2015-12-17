//
//  DownloadAnimationView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-04.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
class DownloadAnimationView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupComponent()
    }
    
    func setupComponent() {
        // Draw the eye
        let eyeLayer = CALayer()
        eyeLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 300, height: 200))
        layer.addSublayer(eyeLayer)
        
        // Top line
        let topLineLayerPath = UIBezierPath()
        topLineLayerPath.moveToPoint(CGPoint(x: 30, y: 75))
        topLineLayerPath.addCurveToPoint(CGPoint(x: 270, y: 75), controlPoint1: CGPoint(x: 120, y: 0), controlPoint2: CGPoint(x: 170, y: 0))
        topLineLayerPath.addCurveToPoint(CGPoint(x: 30, y: 75), controlPoint1: CGPoint(x: 170, y: 150), controlPoint2: CGPoint(x: 120, y: 150))
        
        let topLineLayer = CAShapeLayer()
        topLineLayer.path = topLineLayerPath.CGPath
        topLineLayer.strokeColor = UIColor.whiteColor().CGColor
        topLineLayer.lineWidth = 4
        eyeLayer.addSublayer(topLineLayer)
        
        // Center piece
        let centerPiece = CALayer()
        centerPiece.frame = CGRect(origin: CGPoint(x: 100, y: 25), size: CGSize(width: 100, height: 100))
        layer.addSublayer(centerPiece)
        
        let arrowLayerContainer = CALayer()
        arrowLayerContainer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        centerPiece.addSublayer(arrowLayerContainer)
        
        let arrowLayer = createArrowLayer()
        arrowLayer.position = CGPoint(x: 65, y: 50)
        arrowLayerContainer.addSublayer(arrowLayer)
        
        let circlePath = UIBezierPath(arcCenter: CGPointZero, radius: 30, startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        let circleLayer = CAShapeLayer()
        circleLayer.position = CGPoint(x: 50, y: 50)
        circleLayer.path = circlePath.CGPath
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.strokeColor = Stylesheet.arrowColor.CGColor
        circleLayer.lineWidth = 5.0;
        centerPiece.addSublayer(circleLayer)
        
        let arrowRotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        arrowRotationAnimation.fromValue = 0
        arrowRotationAnimation.duration = 1
        arrowRotationAnimation.toValue = M_PI * 2
        arrowRotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let arrowRotationAnimationGroup = CAAnimationGroup()
        arrowRotationAnimationGroup.duration = 1.5
        arrowRotationAnimationGroup.repeatCount = HUGE
        arrowRotationAnimationGroup.animations = [arrowRotationAnimation]
        
        arrowLayerContainer.addAnimation(arrowRotationAnimationGroup, forKey: "arrowRotation")
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        strokeEndAnimation.duration = 1.0
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let strokeEndAnimationGroup = CAAnimationGroup()
        strokeEndAnimationGroup.duration = 1.5
        strokeEndAnimationGroup.repeatCount = HUGE
        strokeEndAnimationGroup.animations = [strokeEndAnimation]
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.beginTime = 0.5
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.duration = 1.0
        strokeStartAnimation.removedOnCompletion = false
        strokeStartAnimation.fillMode = kCAFillModeForwards
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let strokeStartAnimationGroup = CAAnimationGroup()
        strokeStartAnimationGroup.duration = 1.5
        strokeStartAnimationGroup.removedOnCompletion = false
        strokeStartAnimationGroup.fillMode = kCAFillModeForwards
        strokeStartAnimationGroup.repeatCount = HUGE
        strokeStartAnimationGroup.animations = [strokeStartAnimation]
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = M_PI * 2
        rotationAnimation.duration = 4
        rotationAnimation.repeatCount = HUGE
        
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer.addAnimation(strokeEndAnimationGroup, forKey: "animateCircle")
        circleLayer.addAnimation(strokeStartAnimationGroup, forKey: "animateCircle2")
        centerPiece.addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 300, height: 150)
    }
    
    func createArrowLayer() -> CAShapeLayer {
        let arrowPath = UIBezierPath()
        arrowPath.moveToPoint(CGPoint(x: 0, y: 0))
        arrowPath.addLineToPoint(CGPoint(x: 30, y: 0))
        arrowPath.addLineToPoint(CGPoint(x: 15, y: 15))
        arrowPath.addLineToPoint(CGPoint(x: 0, y: 0))
        
        let arrowLayer = CAShapeLayer()
        arrowLayer.path = arrowPath.CGPath
        arrowLayer.fillColor = Stylesheet.arrowColor.CGColor
        
        return arrowLayer
    }
}
