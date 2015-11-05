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

        downloadView.animationView.startAnimating()
        
        downloadController.download().observeOn(UIScheduler()).startWithNext { (count) -> () in
            print("Downloaded \(count) episodes!")
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
