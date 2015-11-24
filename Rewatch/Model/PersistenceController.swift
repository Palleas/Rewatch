//
//  PersistenceController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-03.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import CoreData
import ReactiveCocoa

class PersistenceScheduler: SchedulerType {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func schedule(action: () -> ()) -> Disposable? {
        let disposable = SimpleDisposable()
        
        context.performBlock { () -> Void in
            guard !disposable.disposed else {
                return
            }
            
            action()
        }
        return disposable
    }
}

class PersistenceController: NSObject {
    typealias InitCallback = () -> Void
    
    enum PersistenceError: ErrorType {
        case InitializationError
        case EntityError
    }
    
    private(set) var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    private(set) var privateObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    
    let initCallback: InitCallback
    
    init(initCallback: InitCallback) throws {
        self.initCallback = initCallback
        
        super.init()

        guard let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") else {
            throw PersistenceError.InitializationError
        }
        
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            throw PersistenceError.InitializationError
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        privateObjectContext.persistentStoreCoordinator = coordinator

        managedObjectContext.parentContext = privateObjectContext
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { () -> Void in
            guard let psc = self.privateObjectContext.persistentStoreCoordinator else { return }
            
            var options = [String: AnyObject]()
            options[NSMigratePersistentStoresAutomaticallyOption] = true
            options[NSInferMappingModelAutomaticallyOption] = true
            options[NSSQLitePragmasOption] = ["journal_mode": "DELETE"]
            
            let fileManager = NSFileManager.defaultManager()
            guard let documentsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last else { return }
            let storeURL = documentsURL.URLByAppendingPathComponent("DataModel.sqlite")
            print("store URL is \(storeURL)")
            do {
                try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.initCallback()
                })
            } catch {
                // TODO how to handle error properly ?
            }
        }
    }
    
    func save() {
//        print("Private Context has changes \(privateObjectContext.hasChanges)")
//        print("Main Context has changes \(managedObjectContext.hasChanges)")
        guard privateObjectContext.hasChanges || managedObjectContext.hasChanges else { return }
        
        managedObjectContext.performBlockAndWait { () -> Void in
            if let _ = try? self.managedObjectContext.save() {
//                print("Saved main context")
                self.privateObjectContext.performBlock({ () -> Void in
                    if let _ = try? self.privateObjectContext.save() {
//                        print("Saved private context")
                    } else {
//                        print("Unable to save private context")
                    }
                })
            } else {
//                print("Unable to save main context")
            }
        }
    }

    func spawnManagedObjectContext() -> NSManagedObjectContext {
        let spawn = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        spawn.parentContext = managedObjectContext
        
        return spawn
    }
    
    func allEpisodes() -> [StoredEpisode] {
        let request = NSFetchRequest(entityName: "Episode")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            let episodes = try managedObjectContext.executeFetchRequest(request)
            return episodes as! [StoredEpisode]
        } catch {
            return []
        }
    }
    
    func numberOfEpisodes() -> Int {
        let request = NSFetchRequest(entityName: "Episode")

        return managedObjectContext.countForFetchRequest(request, error: nil)
    }
    
    func numberOfShows() -> Int {
        let request = NSFetchRequest(entityName: "Show")
        
        return managedObjectContext.countForFetchRequest(request, error: nil)
    }
}

func showWithId(id: Int, inContext managedObjectContext: NSManagedObjectContext) -> StoredShow? {
    let request = NSFetchRequest(entityName: "Show")
    request.predicate = NSPredicate(format: "id = %ld", id)
    request.fetchLimit = 1
    
    let shows = try? managedObjectContext.executeFetchRequest(request)
    return shows?.first as? StoredShow
}

func episodeWithId(id: Int, inContext managedObjectContext: NSManagedObjectContext) -> StoredEpisode? {
    let request = NSFetchRequest(entityName: "Episode")
    request.predicate = NSPredicate(format: "id = %ld", id)
    request.fetchLimit = 1
    
    let shows = try? managedObjectContext.executeFetchRequest(request)
    return shows?.first as? StoredEpisode
}

