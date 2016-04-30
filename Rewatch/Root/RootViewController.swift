//
//  RootViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-21.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import ReactiveCocoa
import enum Result.NoError

class RootViewController: UIViewController {
    let persistenceController: PersistenceController
    let analyticsController: AnalyticsController
    let creditsController: CreditsViewController

    let authenticationController = AuthenticationController()

    private(set) var currentViewController: UIViewController?
    var creditsVisible = false
    var rootView: RootView {
        return view as! RootView
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
        let rootView = RootView()
        rootView.delegate = self

        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(creditsController)
        creditsController.willMoveToParentViewController(self)
        rootView.creditsView = creditsController.view
        creditsController.didMoveToParentViewController(self)
    }


    func boot() {
        authenticationController.contentController.producer
            .flatMap(FlattenStrategy.Latest) { (contentController) -> SignalProducer<UIViewController, NoError> in
                if let _ = contentController {
                    return SignalProducer(value: self.createEpisodeController())
                } else {
                    return SignalProducer(value: self.createLoginViewController())
                }
            }
            .observeOn(UIScheduler())
            .startWithNext { [weak self] viewController in
                self?.transitionToViewController(viewController)
            }

        authenticationController.retrieveContentController()
    }

    // TODO: move this code into a VC factory of some sort
    func createLoginViewController() -> UIViewController {
        let loginViewController = LoginViewController(persistenceController: persistenceController, authenticationController: authenticationController)
        return UINavigationController(rootViewController: loginViewController)
    }

    // TODO: move this code into a VC factory of some sort
    func createEpisodeController() -> UIViewController {
        let episodeViewcontroller = EpisodeViewController(persistenceController: persistenceController, analyticsController: self.analyticsController, contentController: authenticationController.contentController.value!, authenticationController: authenticationController)

        return UINavigationController(rootViewController: episodeViewcontroller)
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
        creditsVisible = !creditsVisible
        rootView.toggleCredits() {
            self.setNeedsStatusBarAppearanceUpdate()

        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return creditsVisible
    }

    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }

    var episodeViewController: EpisodeViewController? {
        get {
            guard let navigation = childViewControllers.first as? UINavigationController else { return nil }
            
            return navigation.viewControllers.filter({ $0 is EpisodeViewController }).first as? EpisodeViewController
        }
    }
}

extension RootViewController: RootViewDelegate {
    func didSwipeContainerBack() {
        creditsVisible = false
        rootView.toggleCredits() {
            self.setNeedsStatusBarAppearanceUpdate()
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
