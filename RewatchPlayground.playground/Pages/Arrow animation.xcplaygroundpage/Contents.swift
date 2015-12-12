//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let view = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 300, height: 300)))

XCPlaygroundPage.currentPage.liveView = view

let centerPiece = CALayer()
centerPiece.frame = CGRect(origin: CGPoint(x: 75, y: 75), size: CGSize(width: 150, height: 150))
view.layer.addSublayer(centerPiece)

let arrowLayerContainer = CALayer()
arrowLayerContainer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 150, height: 150))
centerPiece.addSublayer(arrowLayerContainer)

let arrowLayer = createArrowLayer()
arrowLayer.position = CGPoint(x: 135, y: 75)
arrowLayerContainer.addSublayer(arrowLayer)

let circlePath = UIBezierPath(arcCenter: CGPointZero, radius: 75, startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
let circleLayer = CAShapeLayer()
circleLayer.position = CGPoint(x: 75, y: 75)
circleLayer.path = circlePath.CGPath
circleLayer.fillColor = UIColor.clearColor().CGColor
circleLayer.strokeColor = RewatchColorScheme.mainColor.CGColor
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