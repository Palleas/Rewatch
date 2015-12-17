//
//  CreditsViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-29.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {
    var creditsView: CreditsView {
        get {
            return view as! CreditsView
        }
    }
    
    let analyticsController: AnalyticsController
    
    init(analyticsController: AnalyticsController) {
        self.analyticsController = analyticsController
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let creditsView = CreditsView()
        creditsView.delegate = self
        view = creditsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        creditsView.delegate = self
    }

}

extension CreditsViewController: CreditsViewDelegate {
    func didSelectCreditItem(item: CreditsItem) {
        if let url = item.URL {
            analyticsController.trackEvent(.OpenURL(url))
            
            UIApplication.sharedApplication().openURL(url)
            rootViewController?.toogleCredits()
        }
    }
}