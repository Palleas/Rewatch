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
    private let showSwitch = UISwitch()

    var switched: Bool { return showSwitch.on }

    weak var delegate: ShowTableViewCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        showSwitch.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(showSwitch)

        titleLabel.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor, constant: 10).active = true
        titleLabel.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
        titleLabel.rightAnchor.constraintEqualToAnchor(showSwitch.leftAnchor).active = true
        titleLabel.textColor = Stylesheet.settingsTintColor
        titleLabel.highlightedTextColor = Stylesheet.settingsHighlightedTintColor
        titleLabel.font = Stylesheet.showCellTitleFont

        showSwitch.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor, constant: -10).active = true
        showSwitch.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
        showSwitch.onTintColor = Stylesheet.switchOnTintColor
        showSwitch.addTarget(self, action: #selector(ShowTableViewCell.switchStateDidChange), forControlEvents: .ValueChanged)

        selectedBackgroundView = UIView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithTitle(title: String, includeInRandom: Bool) {
        titleLabel.text = title
        showSwitch.on = includeInRandom
    }

    func toggle() {
        showSwitch.setOn(!showSwitch.on, animated: true)
        showSwitch.sendActionsForControlEvents(.ValueChanged)
    }

    func switchStateDidChange() {
        delegate?.didToggleCell(self, on: showSwitch.on)
    }
}
