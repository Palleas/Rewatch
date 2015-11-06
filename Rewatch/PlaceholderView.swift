//
//  RootView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-04.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class PlaceholderView: UIView {
    let centerImage = UIImageView(image: UIImage(named: "OeilFull"))
    
    init() {
        super.init(frame: CGRectZero)

        centerImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerImage)
        
        centerImage.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        centerImage.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
