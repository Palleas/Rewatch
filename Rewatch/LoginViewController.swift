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
    let client: Client

    var login: LoginView {
        get {
            return view as! LoginView
        }
    }
    
    init(client: Client) {
        self.client = client
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
