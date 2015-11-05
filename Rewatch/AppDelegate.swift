//
//  AppDelegate.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-15.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import KeychainSwift
import Fabric
import Crashlytics
import CoreData

import ReactiveCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var client: Client!
    var persistence: PersistenceController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])

        // Setup stylesheet
        let stylesheet = Stylesheet()
        stylesheet.apply()
        
        // Retrieve API Keys
        let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!) as! [String: String]
        let keychain = KeychainSwift()

        let token = keychain.get("betaseries-token")
        
        client = Client(key: keys["BetaseriesAPIKey"]!, secret: keys["BetaseriesAPISecret"]!, token: token)

        persistence = try! PersistenceController(initCallback: { () -> Void in
            print("Persistence layer is ready")
            if self.client.authenticated {
                let controller = DownloadViewController(client: self.client, downloadController: DownloadController(client: self.client, persistenceController: self.persistence))
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                    self.window?.rootViewController?.presentedViewController?.presentViewController(UINavigationController(rootViewController: controller), animated: true, completion: nil)
                })
            }

        })
        
        (window?.rootViewController as? RootViewController)?.client = client
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        client.completeSigninWithURL(url)
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        persistence.save()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        persistence.save()
    }

    func applicationWillTerminate(application: UIApplication) {
        persistence.save()
    }
}
