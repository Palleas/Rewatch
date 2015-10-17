//
//  ViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-15.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var client: Client!

    @IBAction func authenticate(sender: AnyObject) {
        client.authorize { (token, error) -> Void in
            print(token, error)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("ToShowsSegue", sender: self)
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let vc = segue.destinationViewController as? ShowsViewController {
            vc.client = client
        }
    }
}

