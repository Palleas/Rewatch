//
//  ViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-15.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import Keys

class ViewController: UIViewController {
    let keys = RewatchKeys()

    var client: Client!

    @IBAction func authenticate(sender: AnyObject) {
        guard let comps = NSURLComponents(string: "https://www.betaseries.com/authorize") else { return }

        var items = [NSURLQueryItem]()
        items.append(NSURLQueryItem(name: "client_id", value: keys.betaseriesAPIKey()))
        items.append(NSURLQueryItem(name: "redirect_uri", value: "rewatch://oauth/handle"))
        
        comps.queryItems = items
        
        if let url = comps.URL {
            print("Opening URL \(url)")
            UIApplication.sharedApplication().openURL(url)
        }
        
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
