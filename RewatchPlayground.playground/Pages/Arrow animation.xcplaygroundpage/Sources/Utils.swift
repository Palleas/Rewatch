import UIKit

public struct RewatchColorScheme {
    public static let secondaryColor = UIColor.whiteColor()
    public static let mainColor =  UIColor(red: 247/255, green: 78/255, blue: 64/255, alpha: 1)
}

public func createArrowLayer() -> CAShapeLayer {
    let arrowPath = UIBezierPath()
    arrowPath.moveToPoint(CGPoint(x: 0, y: 0))
    arrowPath.addLineToPoint(CGPoint(x: 30, y: 0))
    arrowPath.addLineToPoint(CGPoint(x: 15, y: 15))
    arrowPath.addLineToPoint(CGPoint(x: 0, y: 0))
    
    let arrowLayer = CAShapeLayer()
    arrowLayer.path = arrowPath.CGPath
    arrowLayer.fillColor = RewatchColorScheme.mainColor.CGColor
    
    return arrowLayer
}