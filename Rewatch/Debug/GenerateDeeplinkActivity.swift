//
//  GenerateDeeplinkActivity.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-24.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class GenerateDeeplinkActivity: UIActivity {

    private(set) var deepLinkViewController: GenerateDeepLinkViewController?
    
    override func activityType() -> String? {
        return "com.perfectly-cooked.Rewatch.generateDeepLink"
    }
    
    override func activityTitle() -> String? {
        return "Generate Deeplink"
    }
    
    override func activityImage() -> UIImage? {
        return nil
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return activityItems.filter({ $0 is StoredEpisode }).count == 1
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        guard let episode = activityItems.filter({ $0 is StoredEpisode }).first as? StoredEpisode else { return }
        
        deepLinkViewController = GenerateDeepLinkViewController(episode: episode, completion: { (result) -> Void in
            print(result)
            self.activityDidFinish(result == GenerateDeepLinkViewController.Result.Completed)
            
        })
    }

    override class func activityCategory() -> UIActivityCategory {
        return .Action
    }
    
    override func activityViewController() -> UIViewController? {
        return deepLinkViewController
    }
    
}
