//
//  EpisodeImageContainerView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-25.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class EpisodeImageContainerView: UIView {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var bnwImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let viewRatio = frame.height / frame.width
        let size = CGSize(width: frame.width, height: frame.width * viewRatio)
        
        let diffX = (frame.width - size.width) / 2
        imageView.frame = CGRect(origin: CGPoint(x: diffX, y: 0), size: size)
        
        bnwImageView.frame = imageView.frame
    }
}
