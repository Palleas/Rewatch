//
//  StoredEpisode.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-04.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import Foundation
import CoreData


class StoredEpisode: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension StoredEpisode {
    static func episodeInContext(context: NSManagedObjectContext, mappedOnEpisode episode: Client.Episode?) -> StoredEpisode {
        let stored = NSEntityDescription.insertNewObjectForEntityForName("StoredEpisode", inManagedObjectContext: context) as! StoredEpisode
        
        if let episode = episode {
            stored.id = episode.id
            stored.title = episode.title
            stored.season = episode.season
            stored.episode = episode.episode
            stored.summary = episode.summary
        }
        
        return stored
    }
}
