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
    static func showInContext(context: NSManagedObjectContext, mappedOnShow show: Client.Show?) -> StoredShow {
        // TODO use throws + attemptMap ?
        let stored = NSEntityDescription.insertNewObjectForEntityForName("Show", inManagedObjectContext: context) as! StoredShow
        
        if let show = show {
            stored.id = Int64(show.id)
            stored.name = show.name
        }
        
        return stored
    }
}