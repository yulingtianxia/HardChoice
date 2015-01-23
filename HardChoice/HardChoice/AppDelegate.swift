//
//  AppDelegate.swift
//  HardChoice
//
//  Created by 杨萧玉 on 14-7-1.
//  Copyright (c) 2014年 杨萧玉. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: -60), forBarMetrics: .Default)
        let navigationController = self.window!.rootViewController as UINavigationController
        let controller = navigationController.topViewController as MasterViewController
        controller.managedObjectContext = managedObjectContext
//        let containerURL = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier("iCloud.com.yulingtianxia.HardChoice")
//        if containerURL != nil {
//            println(containerURL)
//        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func saveContext () {
        var error: NSError? = nil
        let managedObjectContext = self.managedObjectContext
        if managedObjectContext != nil {
            if managedObjectContext.hasChanges && !managedObjectContext.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    // #pragma mark - Core Data stack

    // Returns the managed object context for the application.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    var managedObjectContext: NSManagedObjectContext! {
        if _managedObjectContext == nil {
            let coordinator = self.persistentStoreCoordinator
            if coordinator != nil {
                _managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
                _managedObjectContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                _managedObjectContext?.persistentStoreCoordinator = coordinator
            }
        }
        return _managedObjectContext!
    }
    var _managedObjectContext: NSManagedObjectContext? = nil

    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel: NSManagedObjectModel {
        if _managedObjectModel == nil {
            let modelURL = NSBundle.mainBundle().URLForResource("HardChoice", withExtension: "momd")
            _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        }
        return _managedObjectModel!
    }
    var _managedObjectModel: NSManagedObjectModel? = nil

    // Returns the persistent store coordinator for the application.
    // If the coordinator doesn't already exist, it is created and the application's store added to it.
    var persistentStoreCoordinator: NSPersistentStoreCoordinator! {
        if _persistentStoreCoordinator == nil {
            let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("HardChoice.sqlite")
            var error: NSError? = nil
            _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            
            // iCloud notification subscriptions
            let dc = NSNotificationCenter.defaultCenter()
            dc.addObserverForName(NSPersistentStoreCoordinatorStoresWillChangeNotification, object: self.persistentStoreCoordinator, queue: NSOperationQueue.mainQueue(), usingBlock: { (note) -> Void in
                self.managedObjectContext.performBlock({ () -> Void in
                    var error: NSError? = nil
                    if self.managedObjectContext.hasChanges {
                        if !self.managedObjectContext.save(&error) {
                            println(error?.description)
                        }
                    }
                    self.managedObjectContext.reset()
                })
            })
            dc.addObserverForName(NSPersistentStoreCoordinatorStoresDidChangeNotification, object: self.persistentStoreCoordinator, queue: NSOperationQueue.mainQueue(), usingBlock: { (note) -> Void in
                self.managedObjectContext.performBlock({ () -> Void in
                    var error: NSError? = nil
                    if self.managedObjectContext.hasChanges {
                        if !self.managedObjectContext.save(&error) {
                            println(error?.description)
                        }
                    }
                })
            })
            dc.addObserverForName(NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: self.persistentStoreCoordinator, queue: NSOperationQueue.mainQueue(), usingBlock: { (note) -> Void in
                self.managedObjectContext.performBlock({ () -> Void in
                    self.managedObjectContext.mergeChangesFromContextDidSaveNotification(note)
                })
            })
            
            if _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: [NSPersistentStoreUbiquitousContentNameKey:"MyAppCloudStore"], error: &error) == nil {

                println("Unresolved error \(error), \(error?.userInfo)")
                abort()
            }
        }
        return _persistentStoreCoordinator!
    }
    var _persistentStoreCoordinator: NSPersistentStoreCoordinator? = nil

    // #pragma mark - Application's Documents directory
                                    
    // Returns the URL to the application's Documents directory.
    var applicationDocumentsDirectory: NSURL {
        return NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil,
            create: true,
            error: nil)!
    }
    
    // Subscribe to NSPersistentStoreDidImportUbiquitousContentChangesNotification
    func persistentStoreDidImportUbiquitousContentChanges(note:NSNotification){
        println(note.userInfo?.description)
        managedObjectContext.performBlock {
            self.managedObjectContext.mergeChangesFromContextDidSaveNotification(note)
            NSNotificationCenter.defaultCenter().postNotificationName("notifiCloudStoreDidChange", object: nil)
            
            /*
            // you may want to post a notification here so that which ever part of your app
            // needs to can react appropriately to what was merged.
            // An exmaple of how to iterate over what was merged follows, although I wouldn't
            // recommend doing it here. Better handle it in a delegate or use notifications.
            // Note that the notification contains NSManagedObjectIDs
            // and not NSManagedObjects.
            NSDictionary *changes = note.userInfo;
            NSMutableSet *allChanges = [NSMutableSet new];
            [allChanges unionSet:changes[NSInsertedObjectsKey]];
            [allChanges unionSet:changes[NSUpdatedObjectsKey]];
            [allChanges unionSet:changes[NSDeletedObjectsKey]];
            
            for (NSManagedObjectID *objID in allChanges) {
            // do whatever you need to with the NSManagedObjectID
            // you can retrieve the object from with [moc objectWithID:objID]
            }
            */
        }
    }
    
    // Subscribe to NSPersistentStoreCoordinatorStoresWillChangeNotification
    // most likely to be called if the user enables / disables iCloud
    // (either globally, or just for your app) or if the user changes
    // iCloud accounts.
    
    // Subscribe to NSPersistentStoreCoordinatorStoresDidChangeNotification
    func storesDidChange(note:NSNotification){
        // here is when you can refresh your UI and
        // load new data from the new store
        println("storeDidChange")
        NSNotificationCenter.defaultCenter().postNotificationName("notifiCloudStoreDidChange", object: nil)
    }
}

