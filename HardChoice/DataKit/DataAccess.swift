//
//  DataAccess.swift
//  HardChoice
//
//  Created by 杨萧玉 on 15/3/27.
//  Copyright (c) 2015年 杨萧玉. All rights reserved.
//

import UIKit
import CoreData

public let appGroupIdentifier = "group.com.yulingtianxia.HardChoice"

public class DataAccess:NSObject {
    
    private static let instance = DataAccess()
    public class var sharedInstance : DataAccess {
        return instance
    }
    
    override init() {
        super.init()
        // iCloud notification subscriptions
        let dc = NSNotificationCenter.defaultCenter()
        dc.addObserverForName(NSPersistentStoreCoordinatorStoresWillChangeNotification, object: persistentStoreCoordinator, queue: NSOperationQueue.mainQueue(), usingBlock: { (note) -> Void in
            self.managedObjectContext!.performBlock({ () -> Void in
                var error: NSError? = nil
                if self.managedObjectContext!.hasChanges {
                    if !self.managedObjectContext!.save(&error) {
                        println(error?.description)
                    }
                }
                self.managedObjectContext?.reset()
            })
        })
        dc.addObserverForName(NSPersistentStoreCoordinatorStoresDidChangeNotification, object: persistentStoreCoordinator, queue: NSOperationQueue.mainQueue(), usingBlock: { (note) -> Void in
            self.managedObjectContext!.performBlock({ () -> Void in
                var error: NSError? = nil
                if self.managedObjectContext!.hasChanges {
                    if !self.managedObjectContext!.save(&error) {
                        println(error?.description)
                    }
                }
            })
        })
        dc.addObserverForName(NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: persistentStoreCoordinator, queue: NSOperationQueue.mainQueue(), usingBlock: { (note) -> Void in
            self.managedObjectContext!.performBlock({ () -> Void in
                self.managedObjectContext!.mergeChangesFromContextDidSaveNotification(note)
            })
        })
    }
    
    public func fetchQuestions() -> [String]? {
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Question", inManagedObjectContext: managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "content", ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = sortDescriptors
        var error: NSError?
        return managedObjectContext?.executeFetchRequest(fetchRequest, error: &error)?.map({ (question) -> String in
            return (question as! Question).content
        })
    }
    
    public func fetchChoices(questionName:String?) -> [String]? {
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Choice", inManagedObjectContext: managedObjectContext!)
        fetchRequest.entity = entity
        let all = "*"
        fetchRequest.predicate = NSPredicate(format:"question.content='\(questionName ?? all)'")
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        var error: NSError?
        let hehe = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error)!
        return managedObjectContext?.executeFetchRequest(fetchRequest, error: &error)?.map({ (choice) -> String in
            return (choice as! Choice).name
        })
    }

    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.yxy.iCloudCoreDataTest" in the application's documents Application Support directory.
        //        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        //        return urls[urls.count-1] as! NSURL
        var sharedContainerURL:NSURL? = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(appGroupIdentifier)
        return sharedContainerURL ?? NSURL()
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("HardChoice", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("HardChoice.sqlite")
        var error: NSError? = nil
        
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: [NSPersistentStoreUbiquitousContentNameKey:"MyAppCloudStore"], error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    public lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    public func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
}