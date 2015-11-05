//
//  ViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-15.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import ReactiveCocoa

class LoginViewController: UIViewController {
    var client: Client!

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
        client.authenticate()
            .on(next: { (client) -> () in
                if let token = client.token {
                    print("Storing token \(token)")
                    storeToken(token)
                }
            })
            .observeOn(UIScheduler())
            .startWithNext { (authenticatedClient) -> () in
                self.performSegueWithIdentifier("DownloadSegue", sender: self)
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "REWATCH"
        view.backgroundColor = Stylesheet.appBackgroundColor
    }
    
}
