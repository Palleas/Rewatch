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
    let background = UIImageView(image: UIImage(named: "Oeil"))
    let arrow = UIImageView(image: UIImage(named: "Arrow"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupComponent()
    }
    
    func setupComponent() {
        background.translatesAutoresizingMaskIntoConstraints = false
        addSubview(background)
        
        arrow.translatesAutoresizingMaskIntoConstraints = false
        arrow.contentMode = .Center
        addSubview(arrow)

        background.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        background.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        
        arrow.centerXAnchor.constraintEqualToAnchor(background.centerXAnchor).active = true
        arrow.centerYAnchor.constraintEqualToAnchor(background.centerYAnchor).active = true
    }
    
    override func intrinsicContentSize() -> CGSize {
        return background.image?.size ?? CGSize(width: 95, height: 47)
    }
    
    func startAnimating() {
        // TODO adjust animation because the center is super weird
        // and my head hurts
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = M_PI * 2
        animation.duration = 1
        animation.cumulative = true
        animation.repeatCount = HUGE
        
        arrow.layer.addAnimation(animation, forKey: "rotation")
    }
    
    func stopAnimating() {
        arrow.layer.removeAnimationForKey("rotation")
    }
}
