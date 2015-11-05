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
//            let importMoc = self.persistence.spawnManagedObjectContext()
//
//            self.client
//                .fetchShows()
//                .on(next: { print("Downloading \($0.name) | MT: \(NSThread.isMainThread())") })
//                .map({ show -> StoredShow in
//                    print("Storing \(show.name) | MT: \(NSThread.isMainThread())")
//                    let storedShow = NSEntityDescription.insertNewObjectForEntityForName("Show", inManagedObjectContext: importMoc) as! StoredShow
//                    storedShow.id = Int32(show.id)
//                    storedShow.name = show.name
//                    
//                    return storedShow
//                })
//                .flatMap(FlattenStrategy.Merge, transform: { (storedShow) -> SignalProducer<(StoredShow, StoredEpisode), NSError> in
//                    let showId = storedShow.id.stringValue
//                    let fetchEpisodeSignal = self.client
//                        .fetchEpisodesFromShow(showId)
//                        .filter({ $0.seen })
//                        .map({ (episode) -> StoredEpisode in
//                            let storedEpisode = NSEntityDescription.insertNewObjectForEntityForName("Episode", inManagedObjectContext: importMoc) as! StoredEpisode
//                            storedEpisode.id = episode.id
//                            storedEpisode.title = episode.title
//                            storedEpisode.season = episode.season
//                            storedEpisode.episode = episode.episode
//                            storedEpisode.summary = episode.summary
//                            
//                            return storedEpisode
//                        })
//
//                    return combineLatest(SignalProducer(value: storedShow), fetchEpisodeSignal)
//                })
//                .collect()
//                .flatMap(FlattenStrategy.Latest, transform: { (shows) -> SignalProducer<Int, NSError> in
//                    return SignalProducer { sink, disposable in
//                        try! importMoc.save()
//                        sink.sendNext(shows.count)
//                        sink.sendCompleted()
//                    }
//                })
//                .startWithNext({ (shows) -> () in
//                    print("imported \(shows) shows")
//                })
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
