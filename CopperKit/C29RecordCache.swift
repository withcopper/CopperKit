//
//  CopperRecordCache.swift
//  Copper
//  This class is our basic CopperRecord Database
//
//  Created by Doug Williams on 12/18/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import UIKit
import CoreLocation

public class C29RecordCache: NSObject, NSCoding {
    
    enum Keys: String {
        case Cache = "cache"
        case LastServerSyncTimestamp = "lastServerSyncTimestamp"
    }
    
    // Constant used to find this document in the filesystem; assumed unique
    public static var CacheFile:String = "C29RecordCache"
    static var FileType = FileSystemType.Documents
    
    class var ErrorDoamin: String {
        return "CopperRecordCacheError"
    }
    
    class var UpdateNotification: String {
        return "CopperRecordCacheUpdateNotification"
    }
    
    // Local store for our Records, recordId => Record
    private var cache:[String:CopperRecord] = [String:CopperRecord]()
    // last time the cache synced with the server
    public var lastServerSyncTimestamp: NSDate?
    public var session: C29SessionDataSource?
    
    // MARK: - NSCoding
    // The following two methods allow serialization, etc...
    convenience required public init?(coder decoder: NSCoder) {
        self.init()
        cache = decoder.decodeObjectForKey(Keys.Cache.rawValue) as! [String:CopperRecordObject]
        if let syncTimestamp = decoder.decodeObjectForKey(Keys.LastServerSyncTimestamp.rawValue) as? NSDate {
            lastServerSyncTimestamp = syncTimestamp
        }
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(cache, forKey: Keys.Cache.rawValue)
        if lastServerSyncTimestamp != nil {
            coder.encodeObject(lastServerSyncTimestamp, forKey: Keys.LastServerSyncTimestamp.rawValue)
        }
    }
    
    // MARK: - Our custom class stuff
    
    public func getRecord(scope: C29Scope, includeDeleted: Bool = false) -> CopperRecord? {
        if let record = cache[scope.value!] {
            if record.deleted == false || includeDeleted {
                return record
            }
        }
        return CopperRecord?()
    }
    
    public func getAllRecords(includeDeleted: Bool = false) -> [CopperRecord] {
        var records = [CopperRecord]()
        for scope in cache.keys {
            if let record = getRecord(C29Scope.fromString(scope)!, includeDeleted: includeDeleted) {
                records.append(record)
            }
        }
        return records
    }
    
    
    // MARK: - CRUD method for the cache
    
    // Add or push a record to the front of the order
    public func add(record: CopperRecord) {
        // Update the local caches
        cache.updateValue(record, forKey: record.scope.value!)
        record.deleted = false
        // Write to disk!
        save()
    }
    
    // Clear the cache of records of scope type
    public func remove(scope: C29Scope) {
        if let record = cache[scope.value!] {
            record.deleted = true
        }
        save()
    }
    
    private func removeFromLocalCache(records: [CopperRecord]) {
        for record in records {
            // ensure we're not deleting a record that replaced record
            if let current = getRecord(record.scope) where current.deleted {
                cache.removeValueForKey(record.scope.value!)
            }
        }
    }
    
    // MARK: - Data management methods
    
    public func getNextRecordId() -> String {
        return "current"
    }
    
    // Note: this only remove local copies -- not on the datastore!
    // This is intended to be used by V29Session.resetUser() which we expect will handle server-side deletion, too.
    public func removeAll() {
        cache.removeAll()
        save()
    }
    
    public var status: String {
        var contents = ""
        for scope in C29Scope.All {
            if let string = scope.value {
                var displayString = "nil"
                if let record = getRecord(scope) {
                    if let s = (record as? CopperStringDisplayRecord)?.displayString {
                        displayString = s
                    } else {
                        displayString = "SAVED"
                    }
                }
                contents += "\n\(string): \(displayString). "
            }
        }
        return "\(C29RecordCache.CacheFile) status: total records \(cache.count); \(contents)"
    }
    
    // Clear the cache of records that record.valid == false
    public func removeAllInvalid() {
        for (_, record) in cache {
            if record.valid == false {
                cache.removeValueForKey(record.scope.value!)
            }
        }
    }
    
    // MARK: API Methods
    
    // Save a set of records to the API, use forceUpload = true to push all records regardless of uploaded flag
    public func saveToAPI(session: C29SessionDataSource, records: [CopperRecordObject], forceUpload: Bool = false, callback: ((success: Bool, records: [CopperRecordObject])->())! = nil) {
        // Remove any previously uploaded objects UNLESS we're in a force situation
        var uploads = [CopperRecordObject]()
        for record in records {
            let upload = forceUpload || record.uploaded == false
            if record.valid && !record.deleted && upload {
                uploads.append(record)
            }
        }
            
        // Short circuit if we're done before we start
        if uploads.count == 0 {
            C29Log(.Debug, "CopperRecordObject.saveToAPI all \(records.count) records previously saved")
            callback?(success: true, records: uploads)
            return
        }
        C29Log(.Debug, "CopperRecordCache.saveToAPI uploading \(uploads.count) records")
        
        CopperNetworkActivityRegistry.sharedRegistry.activityBegan()
        session.sessionCoordinator?.saveUserRecords(uploads, callback: { success in
            C29Log(.Debug, "CopperRecordCache.saveToAPI save was successful? \(success)")
            CopperNetworkActivityRegistry.sharedRegistry.activityEnded()
            callback?(success: success, records: uploads)
        })
    }
    
    public func deleteFromAPI(session: C29SessionDataSource, records: [CopperRecordObject], forceDelete: Bool = false, callback: ((success: Bool, records: [CopperRecordObject])->())! = nil) {
        // Remove any previously non-uploaded objects
        var removals = [CopperRecordObject]()
        for record in records {
            if forceDelete || record.deleted == true {
                removals.append(record)
            }
        }
        
        // Short circuit if we're done before we start
        if removals.count == 0 {
            C29Log(.Debug, "CopperRecordCache.deleteFromAPI all \(records.count) saved. No need for deletion")
            callback?(success: true, records: removals)
            return
        }
        C29Log(.Debug, "CopperRecordCache.deleteFromAPI deleting \(removals.count) records")
        
        CopperNetworkActivityRegistry.sharedRegistry.activityBegan()
        session.sessionCoordinator?.deleteUserRecords(removals, callback: { success in
            C29Log(.Debug, "CopperRecordCache  deleteFromAPI save was successful? \(success)")
            CopperNetworkActivityRegistry.sharedRegistry.activityEnded()
            callback?(success: success, records: removals)
        })
    }
    
    public func load() -> Bool {
        if let session = session {
            return load(session.appGroupIdentifier)
        }
        return false
    }
    
    public func deleteFile() {
        if let session = session {
            deleteFile(session.appGroupIdentifier)
        }
    }
    
    public func save() {
        if let session = session {
            save(session.appGroupIdentifier)
        }
    }
}

extension C29RecordCache: FileSaveable {
    public func save(session: C29SessionDataSource, callback: C29SuccessCallback) {
        
        let group = dispatch_group_create()
        // send and sync updates remotely
        let records = self.getAllRecords(true) as! [CopperRecordObject]
        var totalSuccess = true
        
        dispatch_group_enter(group)
        deleteFromAPI(session, records: records, forceDelete: false, callback: {success, deletedRecords in
            if !success {
                totalSuccess = false
            } else if deletedRecords.count > 0 {
                self.removeFromLocalCache(deletedRecords)
                self.saveToPath(session.appGroupIdentifier, path: C29RecordCache.CacheFile, object: self)
            }
            
            self.saveToAPI(session, records: records, forceUpload: false, callback: { success, uploadedRecords in
                if !success {
                    totalSuccess = false
                } else if uploadedRecords.count > 0 {
                    for record in records {
                        record.uploaded = true
                    }
                    self.saveToPath(session.appGroupIdentifier, path: C29RecordCache.CacheFile, object: self)
                }
                dispatch_group_leave(group)
            })

        })
        
        dispatch_group_notify(group, dispatch_get_main_queue(), {
            C29Log(.Debug, "identity.save() was a totalSuccess? \(totalSuccess)")
            if totalSuccess {
                callback(success: true)
                NSNotificationCenter.defaultCenter().postNotificationName(C29RecordCache.UpdateNotification, object: self)
                return
            }else {
                C29Log(.Debug, "We had an API failure saving the records... refreshing user records")
                callback(success: false)
            }
        })
    }
}

extension C29RecordCache:FileLoadable {
    public func set(cache: C29RecordCache) {
        self.cache = cache.cache
    }
}