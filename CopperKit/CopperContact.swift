//
//  CopperContact.swift
//  Copper
//
//  Created by Benjamin Sandofsky on 11/11/15.
//  Copyright © 2015 Copper Technologies, Inc. All rights reserved.
//

import UIKit

enum CopperContactKeys: String {
    case Identifier = "identifier"
    case FullName = "full_name"
    case EmailAddresses = "email_addresses"
    case PhoneNumbers = "phone_numbers"
    case Picture = "picture"
    case PictureURL = "picture_url"
}

public struct CopperContact: Hashable, Equatable {
    
    let ContactDataSeparator = ","

    public let identifier:Int32
    public let fullName:String?
    public let emailAddresses:[String]
    public let phoneNumbers:[String]
    public let picture:UIImage?
    public var pictureURL:NSURL?
    public var displayTitle:String {
        get {
            guard hasAnyContent else {
                return ""
            }
            return fullName ?? emailAddresses.first ?? phoneNumbers.first ?? "Unnamed Contact".localized
        }
    }
    public var sortTitle:String {
        return displayTitle.lowercaseString
    }
    var hasAnyContent:Bool {
        return (fullName ?? emailAddresses.first ?? phoneNumbers.first) != nil
    }
    public var hashValue: Int {
        return identifier.hashValue
    }
    
    // return this contact in format that we will use to upload it to the server
    var inServerDataFormat: ContactsServerDataFormat {
        get {
            var data = [String:AnyObject]()
            if let fullName = fullName {
                data[CopperContactKeys.FullName.rawValue] = fullName
            }
            if emailAddresses.count > 0 {
                data[CopperContactKeys.EmailAddresses.rawValue] = emailAddresses
            }
            if phoneNumbers.count > 0 {
                data[CopperContactKeys.PhoneNumbers.rawValue] = phoneNumbers
            }
            if let pictureURL = pictureURL {
                data[CopperContactKeys.PictureURL.rawValue] = pictureURL.absoluteString
            }
            return ["\(self.identifier)": data]
        }
    }
    
    func toContactBackingDataValuesFormat() -> [String:NSData] {
        var backingData = [String:NSData]()
        if let fullName = self.fullName {
            backingData[CopperContactKeys.FullName.rawValue] = NSKeyedArchiver.archivedDataWithRootObject(fullName)
        }
        if self.emailAddresses.count > 0 {
            backingData[CopperContactKeys.EmailAddresses.rawValue] = NSKeyedArchiver.archivedDataWithRootObject(emailAddresses)
        }
        if self.phoneNumbers.count > 0 {
            backingData[CopperContactKeys.PhoneNumbers.rawValue] = NSKeyedArchiver.archivedDataWithRootObject(phoneNumbers)
        }
        if let picture = self.picture {
            if let png = UIImagePNGRepresentation(picture) {
                let pictureData = png.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                backingData[CopperContactKeys.Picture.rawValue] = NSKeyedArchiver.archivedDataWithRootObject(pictureData)
            }
        }
        if let pictureURL = self.pictureURL {
            backingData[CopperContactKeys.PictureURL.rawValue] = NSKeyedArchiver.archivedDataWithRootObject(pictureURL.absoluteString)
        }
        return backingData
    }
    static func fromContactBackingDataValuesFormat(identifier: Int32, backingData: [String:NSData]) -> CopperContact {
        
        var fullName = String?()
        if let fullNameData = backingData[CopperContactKeys.FullName.rawValue] as NSData? {
            if let n = NSKeyedUnarchiver.unarchiveObjectWithData(fullNameData) as? String {
                fullName = n
            }
        }
        
        var emailAddresses = [String]()
        if let emailAddressData = backingData[CopperContactKeys.EmailAddresses.rawValue] as NSData? {
            if let e = NSKeyedUnarchiver.unarchiveObjectWithData(emailAddressData) as? [String] {
                emailAddresses = e
            }
        }
        
        var phoneNumbers = [String]()
        if let phoneNumberData = backingData[CopperContactKeys.PhoneNumbers.rawValue] as NSData? {
            if let p = NSKeyedUnarchiver.unarchiveObjectWithData(phoneNumberData) as? [String] {
                phoneNumbers = p
            }
        }
        
        var picture = UIImage?()
        if let pictureData = backingData[CopperContactKeys.Picture.rawValue] as NSData? {
            if let base64Encoded = NSKeyedUnarchiver.unarchiveObjectWithData(pictureData) as? String {
                if let decoded = NSData(base64EncodedString: base64Encoded, options: NSDataBase64DecodingOptions(rawValue: 0)) {
                        picture = UIImage(data: decoded)
                }
            }
        }
    
        var pictureURL = NSURL?()
        if let pictureURLData = backingData[CopperContactKeys.PictureURL.rawValue] as NSData? {
            if let u = NSKeyedUnarchiver.unarchiveObjectWithData(pictureURLData) as? String {
                pictureURL = NSURL(string: u)
            }
        }
        
        return CopperContact(identifier: identifier, fullName: fullName, emailAddresses: emailAddresses, phoneNumbers: phoneNumbers, picture: picture, pictureURL: pictureURL)
    }
}

public func ==(lhs: CopperContact, rhs: CopperContact) -> Bool {
    return lhs.identifier == rhs.identifier
}