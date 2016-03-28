//
//  SupportTableViewCell.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2016-03-27.
//  Copyright © 2016 Perfectly-Cooked. All rights reserved.
//

import UIKit

class SupportTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textLabel?.font = Stylesheet.showCellTitleFont
        textLabel?.textColor = .whiteColor()

        imageView?.tintColor = .whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
