//
//  RootViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-21.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    var client: Client!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if client.authenticated {
            print("YAY")
        } else {
            performSegueWithIdentifier("LoginSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let destination = segue.destinationViewController as? LoginViewController {
            destination.client = client
        } else if let wrapper = segue.destinationViewController as? UINavigationController, let destination = wrapper.viewControllers.first as? LoginViewController {
            destination.client = client
        }
    }
}
