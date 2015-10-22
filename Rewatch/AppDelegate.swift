//
//  AppDelegate.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-15.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import KeychainSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var client: Client!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Setup stylesheet
        let stylesheet = Stylesheet()
        stylesheet.apply()
        
        // Retrieve API Keys
        let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!) as! [String: String]
        let keychain = KeychainSwift()
        let token = keychain.get("betaseries-token")
        
        client = Client(key: keys["BetaseriesAPIKey"]!, secret: keys["BetaseriesAPISecret"]!, token: token)
        
        (window?.rootViewController as? RootViewController)?.client = client
        
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        client.completeSigninWithURL(url)
        
        return true
    }

}
