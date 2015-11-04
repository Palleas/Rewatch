//
//  StoredEpisode+CoreDataProperties.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-04.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension StoredEpisode {

    @NSManaged var id: NSNumber?
    @NSManaged var title: String?
    @NSManaged var episode: NSNumber?
    @NSManaged var season: NSNumber?
    @NSManaged var summary: String?

}
