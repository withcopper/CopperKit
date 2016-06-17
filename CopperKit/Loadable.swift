//
//  Loadable.swift
//  Copper
//
//  Created by Benjamin Sandofsky on 11/4/15.
//  Copyright © 2015 Copper Technologies, Inc. All rights reserved.
//

import Foundation

protocol Loadable {
    func load(appGroupIdentifier: String)
}

protocol FileLoadable {
    static var CacheFile:String { get }
    static var FileType:FileSystemType { get }
    func set(_:Self) -> ()
}

extension FileLoadable {
    func load(appGroupIdentifier: String) -> Bool{
        let appGroupURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(appGroupIdentifier)!
        guard let filePath = appGroupURL.URLByAppendingPathComponent(Self.CacheFile).path else {
            return false
        }
        guard let data = NSData(contentsOfFile: filePath) as NSData? else {
            return false
        }
        // remove this if statement to reinstate encryption
        let object = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        if let objectData = object as? Self {
            self.set(objectData)
            return true
        } else {
            return false
        }
        // end remove
        
        // DSW: commenting out for performance, re-add if you want to encrypt data on disk..
        // NOTE: this hasn't been tested or optimized for performance
//        let decrypted = V29SecureFile(V29Session.sharedSession.user.secureSettings).decrypt(data)
//        if let decryptionError = decrypted.error {
//            Utils.displayAlert("Filesystem problem", message: decryptionError.localizedDescription)
//        }
//        guard let decryptedData = decrypted.data else {
//            return false
//        }
//        let object = NSKeyedUnarchiver.unarchiveObjectWithData(decryptedData)
//        if let data = object as? Self {
//            self.set(data)
//            return true
//        } else {
//            return false
//        }
    }

    func deleteFile(appGroupIdentifier: String) {
        let appGroupURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(appGroupIdentifier)!
        let filePath = appGroupURL.URLByAppendingPathComponent(Self.CacheFile).path
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath!)
        } catch _ as NSError {
            // no op
        }
    }
}