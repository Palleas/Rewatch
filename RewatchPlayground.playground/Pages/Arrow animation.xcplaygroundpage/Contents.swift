//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let view = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 300, height: 300)))

XCPlaygroundPage.currentPage.liveView = view

let arrowLayerContainer = CALayer()
arrowLayerContainer.frame = CGRect(origin: CGPoint(x: 50, y: 50), size: CGSize(width: 200, height: 200))
view.layer.addSublayer(arrowLayerContainer)

let arrowLayer = createArrowLayer()
arrowLayer.position = CGPoint(x: 185, y: 100)
arrowLayerContainer.addSublayer(arrowLayer)

let circlePath = UIBezierPath(arcCenter: CGPointZero, radius: 100, startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
let circleLayer = CAShapeLayer()
circleLayer.position = CGPoint(x: 150, y: 150)
circleLayer.path = circlePath.CGPath
circleLayer.fillColor = UIColor.clearColor().CGColor
circleLayer.strokeColor = RewatchColorScheme.mainColor.CGColor
circleLayer.lineWidth = 5.0;
view.layer.addSublayer(circleLayer)

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

let animationGroup = CAAnimationGroup()
animationGroup.duration = 1.5
animationGroup.repeatCount = HUGE
animationGroup.animations = [strokeEndAnimation]

let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
strokeStartAnimation.beginTime = 0.5
strokeStartAnimation.fromValue = 0
strokeStartAnimation.toValue = 1
strokeStartAnimation.duration = 1.0
strokeStartAnimation.removedOnCompletion = false
strokeStartAnimation.fillMode = kCAFillModeForwards
strokeStartAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

let animationGroup2 = CAAnimationGroup()
animationGroup2.duration = 1.5
animationGroup2.removedOnCompletion = false
animationGroup2.fillMode = kCAFillModeForwards
animationGroup2.repeatCount = HUGE
animationGroup2.animations = [strokeStartAnimation]

let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
rotationAnimation.fromValue = 0
rotationAnimation.toValue = M_PI * 2
rotationAnimation.duration = 4
rotationAnimation.repeatCount = HUGE

circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
circleLayer.addAnimation(animationGroup, forKey: "animateCircle")
circleLayer.addAnimation(animationGroup2, forKey: "animateCircle2")
view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")