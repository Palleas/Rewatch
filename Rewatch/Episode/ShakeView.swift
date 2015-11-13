//
//  ShakeView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-27.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class ShakeView: UIStackView {
    @IBOutlet var shakeimageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .robotoWithSize(21)
            titleLabel.textColor = .whiteColor()
        }
    }

    @IBOutlet var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = .robotoWithSize(11)
            subtitleLabel.textColor = .whiteColor()
        }
    }
}
