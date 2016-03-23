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
    let contentController: ContentController
    let persistenceController: PersistenceController
    
    init(client: Client, contentController: ContentController, persistenceController: PersistenceController) {
        self.client = client
        self.contentController = contentController
        self.persistenceController = persistenceController
        
        super.init()
    }
    
    /// Download the content needed to run the application 
    /// and returns the number of episodes available for the random
    func download() -> SignalProducer<Int, ContentError> {
        let importMoc = persistenceController.spawnManagedObjectContext()
        let importScheduler = PersistenceScheduler(context: importMoc)
        
        // Fetch shows
        let fetchShows = contentController.fetchShows()

        // Import shows into local database
        let importShowsSignal = fetchShows.flatMap(.Merge, transform: { (show) -> SignalProducer<StoredShow, ContentError> in
            print("show \(show.title)")
            return SignalProducer { observable, disposable in
                observable.sendNext(StoredShow.showInContext(importMoc, mappedOnShow: show))
                observable.sendCompleted()
            }.startOn(importScheduler)
        })
        
        // Import episode
        let importEpisodesSignal = importShowsSignal.flatMap(.Merge) { (storedShow) -> SignalProducer<(StoredShow, StoredEpisode), ContentError> in
            let fetchEpisodeSignal = self.contentController.fetchEpisodes(Int(storedShow.id))
                .flatMap(FlattenStrategy.Merge, transform: { (episode) -> SignalProducer<StoredEpisode, ContentError> in
                    return SignalProducer { observable, disposable in
                        let storedEpisode = StoredEpisode.episodeInContext(importMoc, mappedOnEpisode: episode)
                        storedEpisode.show = storedShow
                        observable.sendNext(storedEpisode)
                        observable.sendCompleted()
                    }.startOn(importScheduler)
                })
            return combineLatest(SignalProducer(value: storedShow), fetchEpisodeSignal)
        }
        .collect()
        
        let finalCountdownSignalProducer = importEpisodesSignal.flatMap(FlattenStrategy.Latest) { (showsAndEpisodes) -> SignalProducer<Int, ContentError> in
            return SignalProducer<Int, ContentError> { sink, disposable in
                try! importMoc.save()
                sink.sendNext(showsAndEpisodes.count)
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(NSDate(), forKey: DownloadControllerLastSyncKey)
                defaults.synchronize()

                sink.sendCompleted()
            }
        }

        return finalCountdownSignalProducer
    }
    
    func fetchSeenEpisodeFromShow(id: Int) -> SignalProducer<Episode, ContentError> {
        return self.contentController.fetchEpisodes(id)
    }
}
