//
//  Saveable.swift
//  Copper
//
//  Created by Benjamin Sandofsky on 11/4/15.
//  Copyright © 2015 Copper Technologies, Inc. All rights reserved.
//

import Foundation

protocol Saveable:class {
    func save(appGroupIdentifier: String)
}

protocol FileSaveable: Saveable {
    static var CacheFile:String { get }
    static var FileType:FileSystemType { get }
}


// NOTE: before the app group concept, we use to store some data in Caches dir and some in the Documents dir to use iOS's better caching data scheme
// But we had to move away from that with the app group since we don't get that split, only one bucket
// Leaving it here for posterity because it may come in handy.
// Look at check in https://github.com/withcopper/iOS/commit/55f6bdb8ac406d0aba1c230fbf0333f0640e880d for how this was previously used
enum FileSystemType {
    case Documents
    case Caches
    
    var dir: NSSearchPathDirectory {
        switch self {
        case .Documents:
            return NSSearchPathDirectory.DocumentDirectory
        case .Caches:
            return NSSearchPathDirectory.CachesDirectory
        }
    }
}

extension FileSaveable {
    func saveToPath(appGroupIdentifier: String, path: String, object: AnyObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let appGroupURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(appGroupIdentifier)!
            let filePath = appGroupURL.URLByAppendingPathComponent(path).path
            let data = NSKeyedArchiver.archivedDataWithRootObject(object)
            data.writeToFile(filePath!, atomically: true)
            // DSW: commenting out for performance 
            //let encrypted = V29SecureFile(V29Session.sharedSession.user.secureSettings).encrypt(data)
            //encrypted.writeToFile(filePath!, atomically: true)
        })
    }
    func save(appGroupIdentifier: String){
        self.saveToPath(appGroupIdentifier, path: Self.CacheFile, object: self)
    }
}