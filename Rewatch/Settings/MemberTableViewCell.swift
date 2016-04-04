//
//  MemberTableViewCell.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2016-03-27.
//  Copyright © 2016 Perfectly-Cooked. All rights reserved.
//

import UIKit
import class ReactiveCocoa.UIScheduler

protocol MemberTableViewCellDelegate: class {
    func didTapLogoutButton()
}

class MemberTableViewCell: UITableViewCell {
    private let avatarView = UIImageView()
    private let usernameLabel = UILabel()
    private let logoutButton = UIButton(type: .Custom)

    weak var delegate: MemberTableViewCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarView)
        avatarView.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
        avatarView.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor, constant: 10).active = true
        avatarView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
        avatarView.widthAnchor.constraintEqualToConstant(70).active = true
        avatarView.heightAnchor.constraintEqualToConstant(70).active = true
        avatarView.layer.cornerRadius = 35
        avatarView.layer.borderColor = Stylesheet.avatarBorderColor.CGColor
        avatarView.layer.borderWidth = 1
        avatarView.clipsToBounds = true

        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(usernameLabel)
        usernameLabel.textColor = .whiteColor()
        usernameLabel.font = Stylesheet.memberLoginCell
        usernameLabel.topAnchor.constraintEqualToAnchor(avatarView.topAnchor).active = true
        usernameLabel.leftAnchor.constraintEqualToAnchor(avatarView.rightAnchor, constant: 10).active = true
        usernameLabel.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor, constant: -10).active = true

        // TODO highlight color
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logoutButton)
        logoutButton.backgroundColor = Stylesheet.logoutBackoundColor
        logoutButton.titleLabel?.font = Stylesheet.logoutFont
        logoutButton.contentHorizontalAlignment = .Left
        logoutButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        logoutButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 220, bottom: 0, right: 0)
        logoutButton.setImage(UIImage(named: "LogoutArrow"), forState: .Normal)
        logoutButton.setTitle(NSLocalizedString("LOG_OUT", comment: "Log out button title").uppercaseString, forState: .Normal)
        logoutButton.leftAnchor.constraintEqualToAnchor(usernameLabel.leftAnchor).active = true
        logoutButton.bottomAnchor.constraintEqualToAnchor(avatarView.bottomAnchor).active = true
        logoutButton.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor, constant: -10).active = true
        logoutButton.heightAnchor.constraintEqualToConstant(35).active = true
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), forControlEvents: .TouchUpInside)
        logoutButton.layer.cornerRadius = 17

        selectionStyle = .None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithMemberInfos(infos: Member) {
        usernameLabel.text = infos.login

        if let avatarUrl = infos.avatar {
            NSURLSession
                .sharedSession()
                .rac_dataWithRequest(NSURLRequest(URL: avatarUrl))
                .map { UIImage.init(data: $0.0) }
                .observeOn(UIScheduler())
                .startWithNext { [weak self] in self?.avatarView.image = $0 }
        }
    }

    func didTapLogoutButton() {
        delegate?.didTapLogoutButton()
    }
}
