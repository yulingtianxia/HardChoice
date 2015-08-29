//
//  Wormhole.swift
//  HardChoice
//
//  Created by 杨萧玉 on 15/4/3.
//  Copyright (c) 2015年 杨萧玉. All rights reserved.
//

import CoreFoundation

public typealias MessageListenerBlock = (AnyObject) -> Void

let WormholeNotificationName = "WormholeNotificationName"
let center = CFNotificationCenterGetDarwinNotifyCenter()
let helpMethod = HelpMethod()

public class Wormhole: NSObject {
    var applicationGroupIdentifier:String!
    var directory:String?
    var fileManager:NSFileManager!
    var listenerBlocks:Dictionary<String, MessageListenerBlock>!
    /**
    初始化方法
    
    - parameter identifier: AppGroup的Identifier
    - parameter dir:        可选的文件夹名称
    
    - returns: Wormhole实例对象
    */
    public init(applicationGroupIdentifier identifier:String, optionalDirectory dir:String) {
        super.init()
        applicationGroupIdentifier = identifier
        directory = dir
        fileManager = NSFileManager()
        listenerBlocks = Dictionary()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessageNotification:", name: WormholeNotificationName, object: nil)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
        CFNotificationCenterRemoveEveryObserver(center, unsafeAddressOf(self))
    }
    
    // MARK: - Private File Operation Methods
    
    func messagePassingDirectoryPath() -> String? {
        let appGroupContainer = self.fileManager.containerURLForSecurityApplicationGroupIdentifier(applicationGroupIdentifier)
        let appGroupContainerPath = appGroupContainer?.path
        if directory != nil, let directoryPath = appGroupContainerPath, let pathurl = NSURL(string: directoryPath)?.URLByAppendingPathComponent(directory!).path {
            do {
                try fileManager.createDirectoryAtPath(pathurl, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
            return directoryPath
        }
        return nil
    }
    
    func filePathForIdentifier(identifier:String) -> String? {
        if identifier.characters.count != 0, let directoryPath = messagePassingDirectoryPath() {
            let fileName = "\(identifier).archive"
            
            return NSURL(string: directoryPath)?.URLByAppendingPathComponent(fileName).path
        }
        return nil
    }
    
    func writeMessageObject(messageObject:AnyObject, toFileWithIdentifier identifier:String) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(messageObject)
        if let filePath = filePathForIdentifier(identifier) {
            if !data.writeToFile(filePath, atomically: true) {
                return
            }
            else{
                sendNotificationForMessageWithIdentifier(identifier)
            }
        }
    }
    
    func messageObjectFromFileWithIdentifier(identifier:String) -> AnyObject? {
        if let data = NSData(contentsOfFile: filePathForIdentifier(identifier) ?? "") {
            let messageObject: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(data)
            return messageObject
        }
        return nil
    }
    
    func deleteFileForIdentifier(identifier:String) {
        if let filePath = filePathForIdentifier(identifier) {
            do {
                try fileManager.removeItemAtPath(filePath)
            } catch _ {
            }
        }
    }
    
    // MARK: - Private Notification Methods
    
    func sendNotificationForMessageWithIdentifier(identifier:String) {
        CFNotificationCenterPostNotification(center, identifier, nil, nil, true)
    }
    
    func registerForNotificationsWithIdentifier(identifier:String) {
        CFNotificationCenterAddObserver(center, unsafeAddressOf(self), helpMethod.callback, identifier, nil, CFNotificationSuspensionBehavior.DeliverImmediately)
    }
    
    func unregisterForNotificationsWithIdentifier(identifier:String) {
        CFNotificationCenterRemoveObserver(center, unsafeAddressOf(self), identifier, nil)
    }
    
//    func wormholeNotificationCallback(center:CFNotificationCenter!, observer:UnsafeMutablePointer<Void>, name:CFString!, object:UnsafePointer<Void>, userInfo:CFDictionary!) {
//        NSNotificationCenter.defaultCenter().postNotificationName(WormholeNotificationName, object: nil, userInfo: ["identifier":name])
//    }
    
    func didReceiveMessageNotification(notification:NSNotification) {
        let userInfo = notification.userInfo
        if let identifier = userInfo?["identifier"] as? String, let listenerBlock = listenerBlockForIdentifier(identifier), let messageObject: AnyObject = messageObjectFromFileWithIdentifier(identifier) {
            listenerBlock(messageObject)
        }
    }
    
    func listenerBlockForIdentifier(identifier:String) -> MessageListenerBlock? {
        return listenerBlocks[identifier]
    }
    
    //MARK: - Public Interface Methods
    
    public func passMessageObject(messageObject:AnyObject ,identifier:String) {
        writeMessageObject(messageObject, toFileWithIdentifier: identifier)
    }
    
    public func messageWithIdentifier(identifier:String) -> AnyObject? {
        return messageObjectFromFileWithIdentifier(identifier)
    }
    
    public func clearMessageContentsForIdentifier(identifier:String) {
        deleteFileForIdentifier(identifier)
    }
    
    public func clearAllMessageContents() {
        if directory != nil, let directoryPath = messagePassingDirectoryPath() {
            do {
                let messageFiles = try fileManager.contentsOfDirectoryAtPath(directoryPath)
                for path in messageFiles {
                    if let pathurl = NSURL(string: directoryPath)?.URLByAppendingPathComponent(path).path {
                        try fileManager.removeItemAtPath(pathurl)
                    }
                }
            }
            catch _ {
                
            }
        }
    }
    
    public func listenForMessageWithIdentifier(identifier:String, listener:MessageListenerBlock) {
        listenerBlocks[identifier] = listener
        registerForNotificationsWithIdentifier(identifier)
    }
    
    public func stopListeningForMessageWithIdentifier(identifier:String) {
        listenerBlocks[identifier] = nil
        unregisterForNotificationsWithIdentifier(identifier)
    }
}
