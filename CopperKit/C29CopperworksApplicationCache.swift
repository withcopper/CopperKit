//
//  C29CopperworksAppliacationCache.swift
//  Copper
//  This class is our basic Cobject Database
//
//  Created by Doug Williams on 5/9/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import UIKit

public class C29CopperworksApplicationCache: NSObject, NSCoding {
    
    public class var C29CopperworksApplicationCacheRefreshNotification: String {
        return "C29CopperworksApplicationCacheRefreshNotification"
    }

    // Constant used to find this document in the filesystem; assumed unique
    public static var CacheFile = "C29CopperworksApplicationCache"
    static var FileType = FileSystemType.Documents
    public var session: C29SessionDataSource?

    // Local store for our Applications, applications_id => C29CopperworksApplication
    private var cache:[String:C29CopperworksApplication] = [String:C29CopperworksApplication]()

    // MARK: - NSCoding
    // The following two methods allow serialization, etc...
    convenience required public init?(coder decoder: NSCoder) {
        self.init()
        self.cache = decoder.decodeObjectForKey("cache") as! [String: C29CopperworksApplication]
    }

    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(cache, forKey: "cache")
    }
    
    public func getApplications() -> [C29CopperworksApplicationDataSource] {
        var applications = [C29CopperworksApplicationDataSource]()
        for (_, application) in self.cache {
            applications.append(application)
        }
        return applications
    }

    public func getApplication(applicationId: String) -> C29CopperworksApplicationDataSource? {
        let application: C29CopperworksApplicationDataSource? = self.cache[applicationId]
        return application
    }

    public func push(application: C29CopperworksApplication) {
        cache.updateValue(application, forKey: application.id)
        save()
    }

    public func remove(application: C29CopperworksApplicationDataSource) {
        cache.removeValueForKey(application.id)
        save()
        session?.sessionCoordinator?.deleteUserApplication(application) { (success, error) -> () in }
    }

    public func update(replace: C29CopperworksApplication, add: C29CopperworksApplication) {
        remove(replace)
        push(add)
    }
    
    public func setApplications(applications: [C29CopperworksApplication]) {
        cache.removeAll()
        for application in applications {
            cache.updateValue(application, forKey: application.id)
        }
        save()
    }

    // Note: this only remove local copies -- not on Firebase!
    // Intended to be used by resetUser which handles server-side deletion
    public func removeAll() {
        cache.removeAll()
        save()
    }
    
    public var status: String {
        return "\(C29CopperworksApplicationCache.CacheFile) status: total records \(cache.count)"
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
        NSNotificationCenter.defaultCenter().postNotificationName(C29CopperworksApplicationCache.C29CopperworksApplicationCacheRefreshNotification, object: nil)
    }
}

extension C29CopperworksApplicationCache:FileSaveable {
    
}

extension C29CopperworksApplicationCache:FileLoadable {
    public func set(cache: C29CopperworksApplicationCache) {
        self.cache = cache.cache
    }
}