//
//  DownloadController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-04.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result
import CoreData

let DownloadControllerLastSyncKey = "LastSyncKey"

func lastSyncDate() -> String? {
    guard let date = NSUserDefaults.standardUserDefaults().objectForKey(DownloadControllerLastSyncKey) as? NSDate  else {
        return nil
    }

    let formatter = NSDateFormatter()
    formatter.dateStyle = .ShortStyle
    formatter.timeStyle = .ShortStyle
    
    return formatter.stringFromDate(date)
}

class DownloadController: NSObject {
    
    let client: Client
    let persistenceController: PersistenceController
    
    init(client: Client, persistenceController: PersistenceController) {
        self.client = client
        self.persistenceController = persistenceController
        
        super.init()
    }
    
    /// Download the content needed to run the application 
    /// and returns the number of episodes available for the random
    func download() -> SignalProducer<Int, NSError> {
        let importMoc = persistenceController.spawnManagedObjectContext()
        let importScheduler = PersistenceScheduler(context: importMoc)
        
        return client
            .fetchShows()
            .flatMap(FlattenStrategy.Merge, transform: { (show) -> SignalProducer<StoredShow, NSError> in
                return SignalProducer { observable, disposable in
                    observable.sendNext(StoredShow.showInContext(importMoc, mappedOnShow: show))
                    observable.sendCompleted()
                }.startOn(importScheduler)
            })
            .flatMap(.Merge, transform: { (storedShow) -> SignalProducer<(StoredShow, StoredEpisode), NSError> in
                let fetchEpisodeSignal = self.fetchSeenEpisodeFromShow(Int(storedShow.id))
                    .flatMap(FlattenStrategy.Merge, transform: { (episode) -> SignalProducer<StoredEpisode, NSError> in
                        return SignalProducer { observable, disposable in
                            let storedEpisode = StoredEpisode.episodeInContext(importMoc, mappedOnEpisode: episode)
                            storedEpisode.show = storedShow
                            observable.sendNext(storedEpisode)
                            observable.sendCompleted()
                        }.startOn(importScheduler)
                    })
                return combineLatest(SignalProducer(value: storedShow), fetchEpisodeSignal)
            })
            .collect()
            .flatMap(.Latest, transform: { (shows) -> SignalProducer<Int, NSError> in
                return SignalProducer { sink, disposable in
                    try! importMoc.save()
                    sink.sendNext(shows.count)
                    sink.sendCompleted()
                }
            })
            .on(next: { print("Synchronized \($0) episodes") }, completed: {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(NSDate(), forKey: DownloadControllerLastSyncKey)
                defaults.synchronize()
            })
    }
    
    func fetchSeenEpisodeFromShow(id: Int) -> SignalProducer<Client.Episode, NSError> {
        return self.client
            .fetchEpisodesFromShow(id)
            .filter({ $0.seen })
    }
}
