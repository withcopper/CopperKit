//
//  CopperSignatureRecord.swift
//  CopperRecordObject Representation of a avatar
//
//  Created by Doug Williams on 6/2/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import UIKit

public class CopperSignatureRecord: CopperRecordObject, CopperSignature {

    // We do this level of indirection because the JSON parser doesn't know how to deal with UIImage objects
    // So we manage to make it work with this little rodeo. You should call and set avatar, and we'll manage the data dictionary stuff
    // for writing out to the API.
    public var signatureImage: UIImage? {
        didSet {
            if self.signatureImage == nil {
                self.picture = nil
            } else {
                self.picture = UIImagePNGRepresentation(self.signatureImage!)
            }
        }
    }
    
    // This is broken -- we have to methods to access avatar
    // but there is a bug where accessing picture when casting from a CopperRecordObject returns a bad_access error
    // eg (record as? CopperAvatarRecord).picture so we need this method instead
    public func getImage() -> UIImage? {
        if let picture = self.picture {
            return UIImage(data: picture)!
        }
        return UIImage?()
    }
    
    // You shouldn't be calling this directly. This handles serializing the photo data into and out of a JSON acceptable format
    private var picture: NSData? {
        get {
            if let base64Encoded = self.data[ScopeDataKeys.SignatureImage.rawValue] as? String {
                if let decoded = NSData(base64EncodedString: base64Encoded, options: NSDataBase64DecodingOptions(rawValue: 0)) {
                    return decoded
                }
            }
            return NSData?()
        }
        set {
            if let new = newValue?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) {
                self.data[ScopeDataKeys.SignatureImage.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.SignatureImage.rawValue)
            }
            self.uploaded = false
        }
    }
    
    // Note: avatar didSet must fire to set picture,
    // which doesnt appear to happen when you set avatar in the init() function
    // so i removed it from the paramter set to ensure no hard to track down bugs occur
    // SO: set avatar after init
    convenience init(id: String = "current", verified: Bool = false) {
        self.init(scope: C29Scope.Signature, data: nil, id: id, verified: verified)
    }

    override public var valid: Bool {
        return picture != nil
    }
    
//    override func rehydrateDataIfNeeded(session: V29Session, completion: ((record: CopperRecordObject?) -> ())!) {
//        if let avatarUrl = data[ScopeDataKeys.AvatarURL.rawValue] as? String {
//            session.imageCache.getImage(avatarUrl, cacheOnDownload: false, callback: { (image: UIImage?) in
//                self.signatureImage = image
//                completion(record: self)
//            })
//        } else {
//            completion(record: self)
//        }
//    }
}

func ==(lhs: CopperSignatureRecord, rhs: CopperSignatureRecord) -> Bool {
    if lhs.id == rhs.id {
        return true
    }
    return lhs.signatureImage == rhs.signatureImage
}