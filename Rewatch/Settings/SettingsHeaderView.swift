//
//  SettingsHeaderView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2016-03-28.
//  Copyright © 2016 Perfectly-Cooked. All rights reserved.
//

import Foundation
import UIKit

class SettingsHeaderView: UIView {
    typealias ActionHandler = (SettingsHeaderView) -> Void

    private let titleLabel = UILabel()
    private var actionButton: UIButton?

    private let title: String
    private let actionTitle: String?
    private let action: ActionHandler?

    var actionHidden = false {
        didSet {
            actionButton?.hidden = actionHidden
        }
    }

    init(title: String, actionTitle: String? = nil, action: ActionHandler? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.textColor = Stylesheet.settingsTintColor
        titleLabel.font = Stylesheet.settingsSectionTextFont

        addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        titleLabel.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: 10).active = true
        titleLabel.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true

        if let actionTitle = actionTitle {
            let actionButton = UIButton(type: .Custom)
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            actionButton.titleLabel?.font = Stylesheet.settingsSectionActionButtonTextFont
            actionButton.setTitle(actionTitle, forState: .Normal)
            actionButton.setTitleColor(Stylesheet.settingsTintColor, forState: .Normal)
            actionButton.setTitleColor(Stylesheet.settingsHighlightedTintColor, forState: .Highlighted)
            actionButton.setTitleColor(Stylesheet.settingsHighlightedTintColor, forState: .Selected)
            actionButton.addTarget(self, action: #selector(SettingsHeaderView.didTapOnButton), forControlEvents: .TouchUpInside)
            addSubview(actionButton)

            actionButton.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
            actionButton.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: -10).active = true

            self.actionButton = actionButton
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func didTapOnButton() {
        action?(self)
    }
}