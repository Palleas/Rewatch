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
import Mixpanel

import ReactiveCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var client: Client!
    var persistence: PersistenceController!
    var analyticsController: AnalyticsController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])

        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        // Setup stylesheet
        let stylesheet = Stylesheet()
        stylesheet.apply()
        
        // Retrieve API Keys
        let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!) as! [String: String]
        
        analyticsController = MixpanelAnalyticsController(mixpanel: Mixpanel.sharedInstanceWithToken(keys["MixpanelAPIKey"]!))

        let keychain = KeychainSwift()
        let token = keychain.get("betaseries-token")
        
        client = Client(key: keys["BetaseriesAPIKey"]!, secret: keys["BetaseriesAPISecret"]!, token: token)

        // Setup Window
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window = window

        persistence = try! PersistenceController(initCallback: { () -> Void in
            if let rootViewController = window.rootViewController as? RootViewController {
                rootViewController.boot()
            }
        })

        window.rootViewController = RootViewController(client: self.client, persistenceController: self.persistence, analyticsController: analyticsController)
        window.makeKeyAndVisible()
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        guard let host = url.host else { return false }

        if host == "oauth" {
            client.completeSigninWithURL(url)
        } else if host == "episode" {
            if let episode = url.pathComponents?.filter({ $0 != "/" }).first, let episodeId = Int(episode) {
                guard let presentedEpisode = episodeWithId(episodeId, inContext: persistence.managedObjectContext) else {
                    return true
                }
                
                let episodeViewController = (window?.rootViewController as? RootViewController)?.episodeViewController
                episodeViewController?.presentEpisode(presentedEpisode)
            }
        }
        
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
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let downloadController = DownloadController(client: client, persistenceController: persistence)
        downloadController
            .download()
            .on(error: { _ in completionHandler(.Failed) })
            .startWithNext({ completionHandler($0 > 0 ? .NewData : .NoData) })
    }
}
