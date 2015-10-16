//
//  ShowsViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-16.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class ShowsViewController: UIViewController {

    var client: Client!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        client.fetchShows { (shows) -> Void in
            
        }
    }
}
