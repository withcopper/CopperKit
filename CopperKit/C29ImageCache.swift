//
//  CopperImageCache.swift
//  Copper
//  This class is our basic Cobject Database
//
//  Created by Doug Williams on 11/17/15.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import UIKit

public class C29ImageCache: NSObject, NSCoding {

    // Constant used to find this document in the filesystem; assumed unique
    public static var CacheFile = "C29ImageCache"
    static var FileType = FileSystemType.Caches

    // Local store for our images, url => UIImage
    private var cache:[String:UIImage] = [String:UIImage]()
    public var session: C29SessionDataSource?
    
    // MARK: - NSCoding
    // The following two methods allow serialization, etc...
    convenience required public init?(coder decoder: NSCoder) {
        self.init()
        self.cache = decoder.decodeObjectForKey("cache") as! [String: UIImage]
    }

    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(cache, forKey: "cache")
    }

    public func getImage(url: String, cacheOnDownload: Bool = true, callback: (image: UIImage?)->()) {
        if let image = cache[url] {
            callback(image: image)
            return
        }
        UIImage.c29_imageFromUrl(url, callback: { returnedImage in
            if returnedImage != nil && cacheOnDownload {
                self.update(returnedImage, forUrl: url)
            }
            callback(image: returnedImage)
        })
    }

    public func update(image: UIImage?, forUrl: String) {
        if image == nil {
            remove(forUrl)
        } else {
            cache.updateValue(image!, forKey: forUrl)
        }
        save()
    }

    public func remove(url: String) {
        cache.removeValueForKey(url)
        save()
    }

    public func removeAll() {
        cache.removeAll()
        save()
    }
    
    public var status: String {
        return "\(C29ImageCache.CacheFile) status: total images \(cache.count)"
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

extension C29ImageCache:FileSaveable {
    
}

extension C29ImageCache:FileLoadable {
    public func set(cache: C29ImageCache) {
        self.cache = cache.cache
    }
}