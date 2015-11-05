//
//  RootViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-21.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    let client: Client
    let persistenceController: PersistenceController
    
    init(client: Client, persistenceController: PersistenceController) {
        self.client = client
        self.persistenceController = persistenceController
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = RootView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if client.authenticated {
            let episodeViewController = UINavigationController(rootViewController: EpisodeViewController(client: client, persistenceController: persistenceController))
            presentViewController(episodeViewController, animated: true, completion: nil)
        } else {
            let login = LoginViewController(client: client)
            presentViewController(UINavigationController(rootViewController: login), animated: true, completion: nil)
        }
    }
    
}
