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
    let persistenceController: PersistenceController
    let analyticsController: AnalyticsController
    let creditsController: CreditsViewController

    let authenticationController = AuthenticationController()

    private(set) var currentViewController: UIViewController?
    
    var rootView: RootView {
        get {
            return view as! RootView
        }
    }
    
    init(persistenceController: PersistenceController, analyticsController: AnalyticsController) {
        self.persistenceController = persistenceController
        self.analyticsController = analyticsController
        self.creditsController = CreditsViewController(analyticsController: analyticsController)
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = RootView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(creditsController)
        creditsController.willMoveToParentViewController(self)
        rootView.creditsView = creditsController.view
        creditsController.didMoveToParentViewController(self)
    }


    func boot() {
        // TODO: There is probablt something nicer to be done here
        // Like Flow controller with SignalProducers and shit
        authenticationController.member.producer.observeOn(UIScheduler()).startWithNext { [weak self] member in
            guard let strongSelf = self else { return }

            if let _ = member, let contentController = self?.authenticationController.contentController {
                let episode = EpisodeViewController(persistenceController: strongSelf.persistenceController, analyticsController: strongSelf.analyticsController, contentController: contentController, authenticationController: strongSelf.authenticationController)
                strongSelf.transitionToViewController(UINavigationController(rootViewController: episode))
            } else {
                let login = LoginViewController(persistenceController: strongSelf.persistenceController)
                login
                    .contentController
                    .producer
                    .filter { $0 is BetaseriesContentController }
                    .observeOn(UIScheduler())
                    .startWithNext { [weak self] contentController in
                        guard let strongSelf = self else { return }
                        strongSelf.authenticationController.saveToken(contentController.rawLogin!)
                        strongSelf.authenticationController.contentController = contentController
                }
                strongSelf.transitionToViewController(UINavigationController(rootViewController: login))
            }
        }
    }

    func presentEpisodeViewController() {
        if let contentController = authenticationController.retrieveContentController() {
            let episode = EpisodeViewController(persistenceController: self.persistenceController, analyticsController: self.analyticsController, contentController: contentController, authenticationController: authenticationController)
            transitionToViewController(UINavigationController(rootViewController: episode))
        } else {
            let login = LoginViewController(persistenceController: self.persistenceController)
            login
                .contentController
                .producer
                .filter { $0 is BetaseriesContentController }
                .observeOn(UIScheduler())
                .startWithNext { [weak self] contentController in
                    guard let strongSelf = self else { return }
                    strongSelf.authenticationController.saveToken(contentController.rawLogin!)
                    strongSelf.authenticationController.contentController = contentController

                    let episode = EpisodeViewController(persistenceController: strongSelf.persistenceController, analyticsController: strongSelf.analyticsController, contentController: contentController, authenticationController: strongSelf.authenticationController)

                    strongSelf.dismissViewControllerAnimated(true) {
                        strongSelf.transitionToViewController(UINavigationController(rootViewController: episode))
                    }
            }
            presentViewController(UINavigationController(rootViewController: login), animated: true, completion: nil)
        }
    }
    
    func transitionToViewController(controller: UIViewController) {
        addChildViewController(controller)
        controller.willMoveToParentViewController(self)
        rootView.transitionToView(controller.view)
        controller.didMoveToParentViewController(self)
        
        currentViewController?.removeFromParentViewController()
        currentViewController = controller
    }
    
    func toogleCredits() {
        analyticsController.trackEvent(.Credits)
        rootView.toggleCredits()
    }
    
    var episodeViewController: EpisodeViewController? {
        get {
            guard let navigation = childViewControllers.first as? UINavigationController else { return nil }
            
            return navigation.viewControllers.filter({ $0 is EpisodeViewController }).first as? EpisodeViewController
        }
    }
}

extension UIViewController {
    var rootViewController: RootViewController? {
        get {
            if let rootViewController = parentViewController as? RootViewController {
                return rootViewController
            }
            
            return parentViewController?.rootViewController
        }
    }
}
