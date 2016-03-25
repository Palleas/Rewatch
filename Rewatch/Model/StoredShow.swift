//
//  StoredShow.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-03.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import Foundation
import CoreData


class StoredShow: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}


extension StoredShow {
    static func showInContext(context: NSManagedObjectContext, mappedOnShow show: Show) -> StoredShow {
        // TODO use throws + attemptMap ?
        let stored: StoredShow
        
        if let localStored = showWithId(show.id, inContext: context) {
            stored = context.objectWithID(localStored.objectID) as! StoredShow
        } else {
            stored = NSEntityDescription.insertNewObjectForEntityForName("Show", inManagedObjectContext: context) as! StoredShow
        }

        stored.id = Int64(show.id)
        stored.title = show.title
        
        return stored
    }
}