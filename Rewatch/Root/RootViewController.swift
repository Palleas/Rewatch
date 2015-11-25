//
//  RootViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-21.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import ReactiveCocoa

class RootViewController: UIViewController {
    let client: Client
    let persistenceController: PersistenceController
    let analyticsController: AnalyticsController
    
    var rootView: RootView {
        get {
            return view as! RootView
        }
    }
    
    init(client: Client, persistenceController: PersistenceController, analyticsController: AnalyticsController) {
        self.client = client
        self.persistenceController = persistenceController
        self.analyticsController = analyticsController
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = RootView()
    }
    
    func boot() {
        client.authenticated.producer.observeOn(UIScheduler()).startWithNext { (authenticated) -> () in
            let target: UIViewController

            if authenticated {
                let episode = EpisodeViewController(client: self.client, persistenceController: self.persistenceController, analyticsController: self.analyticsController)
                target = UINavigationController(rootViewController: episode)
            } else {
                let login = LoginViewController(client: self.client, persistenceController: self.persistenceController)
                target = UINavigationController(rootViewController: login)
            }

            self.transitionToViewController(target)
        }
    }
    
    func transitionToViewController(controller: UIViewController) {
        let currentViewController = childViewControllers.first
        
        addChildViewController(controller)
        controller.willMoveToParentViewController(self)
        rootView.transitionToView(controller.view)
        controller.didMoveToParentViewController(self)
        
        currentViewController?.removeFromParentViewController()
    }
    
    var episodeViewController: EpisodeViewController? {
        get {
            guard let navigation = childViewControllers.first as? UINavigationController else { return nil }
            
            return navigation.viewControllers.filter({ $0 is EpisodeViewController }).first as? EpisodeViewController
        }
    }
    
}
