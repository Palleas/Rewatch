//
//  DownloadViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-21.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import ReactiveCocoa

class DownloadViewController: UIViewController {
    let client: Client
    let downloadController: DownloadController
    
    var downloadView: DownloadView {
        get {
            return view as! DownloadView
        }
    }
    
    init(client: Client, downloadController: DownloadController) {
        self.client = client
        self.downloadController = downloadController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "REWATCH"
        view.backgroundColor = Stylesheet.appBackgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        downloadController.download().observeOn(UIScheduler()).startWithNext { (count) -> () in
            if count == 0 {
                let title = NSLocalizedString("NO_TV_SHOWS_TITLE", comment: "No TV Shows alert title")
                let message = NSLocalizedString("NO_TV_SHOWS_MESSAGE", comment: "No TV Shows alert message")
                let dismiss = NSLocalizedString("NO_TV_SHOWS_DISMISS", comment: "No TV Shows alert dismiss button label")
                let visitBetaseries = NSLocalizedString("NO_TV_SHOWS_VISIT", comment: "No TV Shows alert visit betaseries button label")
                let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: dismiss, style: .Cancel, handler: { (_) -> Void in
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: visitBetaseries, style: .Default, handler: { (_) -> Void in
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                        UIApplication.sharedApplication().openURL(NSURL(string: "https://betaseries.com")!)
                    })
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}
