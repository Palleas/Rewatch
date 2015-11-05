//
//  LoginView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-04.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

protocol LoginViewDelegate: class {
    func didStartAuthenticationInLoginView(loginView: LoginView)
}

class LoginView: UIView {
    weak var delegate: LoginViewDelegate?
    
    @IBOutlet weak var authenticateButton: UIButton! {
        didSet {
            authenticateButton.setTitleColor(.whiteColor(), forState: .Normal)
            authenticateButton.titleLabel?.font = Stylesheet.buttonFont
            authenticateButton.layer.borderColor = Stylesheet.buttonBorderColor.CGColor
            authenticateButton.layer.borderWidth = 1.0
        }
    }
    
    @IBOutlet weak var explanationLabel: UILabel! {
        didSet {
            explanationLabel.textColor = Stylesheet.explainationTextColor
            explanationLabel.font = Stylesheet.explainationFont
        }
    }
    
    @IBAction func authenticate(sender: AnyObject) {
        delegate?.didStartAuthenticationInLoginView(self)
    }
}
