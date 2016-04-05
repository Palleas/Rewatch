//
//  ShowTableViewCell.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2016-03-27.
//  Copyright © 2016 Perfectly-Cooked. All rights reserved.
//

import UIKit

protocol ShowTableViewCellDelegate: class {
    func didToggleCell(cell: ShowTableViewCell, on: Bool)
}

class ShowTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let showCheckmark = UIImageView(image: UIImage(named: "check"))

    weak var delegate: ShowTableViewCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        showCheckmark.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(showCheckmark)

        titleLabel.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor, constant: 10).active = true
        titleLabel.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
        titleLabel.rightAnchor.constraintEqualToAnchor(showCheckmark.leftAnchor).active = true
        titleLabel.textColor = Stylesheet.settingsTintColor
        titleLabel.highlightedTextColor = Stylesheet.settingsHighlightedTintColor
        titleLabel.font = Stylesheet.showCellTitleFont

        showCheckmark.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor, constant: -10).active = true
        showCheckmark.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true

        selectedBackgroundView = UIView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithTitle(title: String, includeInRandom: Bool) {
        titleLabel.text = title
        showCheckmark.hidden = !includeInRandom
    }
}
