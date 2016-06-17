//
//  CopperPictureRecord.swift
//  CopperRecordObject Representation of a avatar
//
//  Created by Doug Williams on 6/2/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import UIKit

public class CopperPictureRecord: CopperRecordObject, CopperPicture {

    // We do this level of indirection because the JSON parser doesn't know how to deal with UIImage objects
    // So we manage to make it work with this little rodeo. You should call and set avatar, and we'll manage the data dictionary stuff
    // for writing out to the API.
    public var image: UIImage? {
        didSet {
            if self.image == nil {
                self.picture = nil
            } else {
                self.picture = UIImagePNGRepresentation(self.image!)
            }
        }
    }
    
    // This is broken -- we have to methods to access avatar
    // but there is a bug where accessing picture when casting from a CopperRecordObject returns a bad_access error
    // eg (record as? CopperAvatarRecord).picture so we need this method instead
    public func getPicture() -> UIImage? {
        if let picture = self.picture {
            return UIImage(data: picture)!
        }
        return UIImage?()
    }
    
    public var url: String? {
        get {
            if let url = data[ScopeDataKeys.PictureURL.rawValue] as? String {
                return url
            }
            return nil
        }
        set {
            if let new = newValue {
                self.data[ScopeDataKeys.PictureURL.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.PictureURL.rawValue)
            }
            self.uploaded = false
        }
    }
    
    // You shouldn't be calling this directly. This handles serializing the photo data into and out of a JSON acceptable format
    private var picture: NSData? {
        get {
            if let base64Encoded = self.data[ScopeDataKeys.PictureImage.rawValue] as? String {
                if let decoded = NSData(base64EncodedString: base64Encoded, options: NSDataBase64DecodingOptions(rawValue: 0)) {
                    return decoded
                }
            }
            return NSData?()
        }
        set {
            if let new = newValue?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) {
                self.data[ScopeDataKeys.PictureImage.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.PictureURL.rawValue)
            }
            self.uploaded = false
        }
    }
    
    // Note: avatar didSet must fire to set picture,
    // which doesnt appear to happen when you set avatar in the init() function
    // so i removed it from the paramter set to ensure no hard to track down bugs occur
    // SO: set avatar after init
    public convenience init(image: UIImage! = nil, id: String = "current", verified: Bool = false) {
        self.init(scope: C29Scope.Picture, data: nil, id: id, verified: verified)
        self.image = image
    }

    public override var valid: Bool {
        return picture != nil
    }
    
    override func rehydrateDataIfNeeded(session: C29SessionDataSource?, completion: ((record: CopperRecordObject?) -> ())!) {
        // create a temporary image cache in case we need one
        var imageCache = C29ImageCache()
        var cacheOnDownload = false
        // if we did get a session object, then let's atempt to use it's cache for optimization
        if let sessionImageCache = session?.imageCache {
            imageCache = sessionImageCache
            cacheOnDownload = true
        }
        if let url = url {
            imageCache.getImage(url, cacheOnDownload: cacheOnDownload, callback: { (image: UIImage?) in
                self.image = image
                completion(record: self)
            })
        } else {
            completion(record: self)
        }
    }

    public class func getAvatarRecordForInitials(initials: String, session: C29SessionDataSource! = nil) -> CopperPicture {
        let record =  CopperPictureRecord()
        record.url = "https://bytes.withcopper.com/default/\(initials.uppercaseString).png"
        record.rehydrateDataIfNeeded(session, completion: { record in
            // no op
        })
        return record
    }
}

func ==(lhs: CopperPictureRecord, rhs: CopperPictureRecord) -> Bool {
    if lhs.id == rhs.id {
        return true
    }
    return lhs.picture == rhs.picture
}