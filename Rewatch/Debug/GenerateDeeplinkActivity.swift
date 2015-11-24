//
//  GenerateDeeplinkActivity.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-24.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class GenerateDeeplinkActivity: UIActivity {

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
        return true
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        
    }

    override class func activityCategory() -> UIActivityCategory {
        return .Action
    }
    
    override func activityViewController() -> UIViewController? {
        return GenerateDeepLinkViewController()
    }
    
}
