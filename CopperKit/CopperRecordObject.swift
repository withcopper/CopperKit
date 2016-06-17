//
//  CopperRecordObject.swift
//  Copper
//  This is our work-horse class, holding the logic for all operations dealing with Records
//  and talking back to the network about them.
//
//  Created by Doug Williams on 12/18/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import UIKit

typealias CopperRecordObjectDataFormat = [String:AnyObject]

public class CopperRecordObject: NSObject, NSCoding, NSCopying, CopperRecord {
    
    enum Keys: String {
        case Scope = "scope"
        case Id = "id"
        case Data = "data"
        case Timestamp = "timestamp"
        case Verified = "verified"
        case Uploaded = "uploaded"
    }

    public var scope: C29Scope
    public var id: String
    var data: CopperRecordObjectDataFormat
    public var verified = false
    public var timestamp: NSDate?
    public var uploaded: Bool = false
    public var deleted = false // used by copper record cache only, never persisted to disk
    public var isBlank: Bool {
        return false
    }
    
    public var delegate: CopperRecordObjectDelegate?
    
    public var dictionary: NSDictionary {
        get {
            let d = NSMutableDictionary()
            d[Keys.Id.rawValue] = id
            if verified {
                d[Keys.Verified.rawValue] = verified
            }
            if timestamp != nil {
                d[Keys.Timestamp.rawValue] = (timestamp!.timeIntervalSince1970 * 1000) // in ms since that's what the server expects
            }
            for (key, value) in data {
                d[key] = value
            }
            return d
        }
    }
    
    init(scope: C29Scope, data: [String: AnyObject]! = nil, id: String, timestamp: NSDate! = nil, verified: Bool = false, uploaded: Bool = false) {
        self.scope = scope
        self.id = id
        self.data = (data != nil) ? data : [String:AnyObject]()
        self.timestamp = timestamp
        self.verified = verified
        self.uploaded = uploaded
        super.init()
    }
    
    required convenience public init(coder decoder: NSCoder) {
        // must be sure that the scope lookup is going to work given the !
        let scope = C29Scope(rawValue: (decoder.decodeObjectForKey(Keys.Scope.rawValue) as! Int))!
        let id = decoder.decodeObjectForKey(Keys.Id.rawValue) as! String
        let data = decoder.decodeObjectForKey(Keys.Data.rawValue) as! [String: AnyObject]
        let timestamp = decoder.decodeObjectForKey(Keys.Timestamp.rawValue) as? NSDate
        let verified = decoder.decodeObjectForKey(Keys.Verified.rawValue) as! Bool
        let uploaded = (decoder.decodeObjectForKey(Keys.Uploaded.rawValue) as? Bool) ?? false
        self.init(scope: scope, data: data, id: id, timestamp: timestamp, verified: verified, uploaded: uploaded)
    }

    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(scope.rawValue, forKey: Keys.Scope.rawValue)
        coder.encodeObject(data, forKey: Keys.Data.rawValue)
        coder.encodeObject(id, forKey: Keys.Id.rawValue)
        coder.encodeObject(timestamp, forKey: Keys.Timestamp.rawValue)
        coder.encodeObject(verified, forKey: Keys.Verified.rawValue)
        coder.encodeObject(uploaded, forKey: Keys.Uploaded.rawValue)
    }

    public class func fromDictionary(scope: C29Scope, dataDict: NSDictionary, session: C29SessionDataSource?, completion: ((record: CopperRecordObject?)->())) {
        // requires
        let id: String = dataDict[Keys.Id.rawValue] as? String ?? "current"
        let data = dataFromDictionary(scope, dataDict: dataDict)
        // handle optionals below this line
        var timestamp: NSDate?
        if let date = dataDict[Keys.Timestamp.rawValue] as? Double {
            timestamp = NSDate(timeIntervalSince1970: date)
        }
        let verified = (dataDict[Keys.Verified.rawValue] as? Bool) ?? false
        if let record = scope.createRecord() {
            record.id = id
            record.data = data
            record.timestamp = timestamp
            record.verified = verified
            record.rehydrateDataIfNeeded(session, completion: { record in
                completion(record: record)
                return
            })
        } else {
            completion(record: CopperRecordObject?())
            return
        }
    }
    
    class func dataFromDictionary(scope: C29Scope, dataDict: NSDictionary) -> CopperRecordObjectDataFormat {
        var data = CopperRecordObjectDataFormat()
        for key in scope.dataKeys {
            data[key.rawValue] = dataDict[key.rawValue]
        }
        return data
    }
    
    // this method should be overwritten by subclasses that need to be rehydrated in anyway upon download from the API.
    // for example,  use this method to download images from URL... see CopperAvatarRecord for an example
    func rehydrateDataIfNeeded(session: C29SessionDataSource?, completion: ((record: CopperRecordObject?)->())! = nil) {
        completion?(record: self)
    }

    // returns true if the cobject conforms to all requirements of its Type, should be overridden by each subclass
    // but we should respect this if it's true "if super.valid { return true }"
    // this is used by CopperRecordCache and the UI to determine when to save / fail a record to the db or UI
    public var valid: Bool {
        return false
    }
    
    // implementation for NSCopying, which allow us to deep copy this object
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = CopperRecordObject(scope: scope, data: data, id: id, timestamp: timestamp, verified: verified, uploaded: uploaded)
        return copy
    }
}

func ==(lhs: CopperRecordObject, rhs: CopperRecordObject) -> Bool {
    return lhs.id == rhs.id
}