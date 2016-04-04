//
//  SupportTableViewCell.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2016-03-27.
//  Copyright © 2016 Perfectly-Cooked. All rights reserved.
//

import UIKit
import CoreGraphics

class SupportTableViewCell: UITableViewCell {

    var icon: UIImage? {
        get {
            return imageView?.image
        }

        set(newIcon) {
            imageView?.image = newIcon

            if let newIcon = newIcon {
                imageView?.highlightedImage = tintImage(newIcon, color: Stylesheet.settingsHighlightedTintColor)
            } else {
                imageView?.highlightedImage = nil
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textLabel?.font = Stylesheet.showCellTitleFont
        textLabel?.textColor = Stylesheet.settingsTintColor
        textLabel?.highlightedTextColor = Stylesheet.settingsHighlightedTintColor

        imageView?.tintColor = Stylesheet.settingsTintColor

        selectedBackgroundView = UIView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
