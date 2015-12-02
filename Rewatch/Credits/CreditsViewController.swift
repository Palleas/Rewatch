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
            UIApplication.sharedApplication().openURL(url)
            rootViewController?.toogleCredits()
        }
    }
}