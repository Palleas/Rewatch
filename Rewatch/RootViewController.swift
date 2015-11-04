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
            let episodeViewController = UINavigationController(rootViewController: EpisodeViewController(client: client))
            presentViewController(episodeViewController, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("LoginSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        // I hate this so much it hurts
        if let destination = segue.destinationViewController as? LoginViewController {
            destination.client = client
        } else if let wrapper = segue.destinationViewController as? UINavigationController, let destination = wrapper.viewControllers.first as? LoginViewController {
            destination.client = client
        }
    }
}
