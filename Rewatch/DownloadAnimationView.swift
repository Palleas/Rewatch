//
//  DownloadAnimationView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-04.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

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
        addSubview(arrow)
        
        background.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        background.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        background.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        background.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        
        arrow.centerXAnchor.constraintEqualToAnchor(background.centerXAnchor).active = true
        arrow.centerYAnchor.constraintEqualToAnchor(background.centerYAnchor).active = true
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 191, height: 95)
    }
}
