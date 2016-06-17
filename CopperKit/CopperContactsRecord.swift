//
//  CopperContactsRecord.swift
//  CopperContactsRecord Representation of a person's contact database
//
//  Created by Doug Williams on 6/4/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import UIKit

public let CopperContactsFavoritesLimit = 29

// format for the data we use in the filesystem to work with NSCoding
// [identifier: [key: nsdata]
typealias ContactBackingData = [String : [String:NSData]]

// format for the data we send to the server
// [identifier: [key : data]]
// e.g. [123: [fullName: "Doug Williams"],["emailAddresses": ["doug@withcopper.com,dougw@igudo.com"]]
typealias ContactsServerDataFormat = [String : [String:AnyObject]]

public class CopperContactsRecord: CopperRecordObject, CopperContacts {

    public override var dictionary: NSDictionary {
        get {
            let d = NSMutableDictionary()
            // get 'verified' and 'timestamp' and any other standard keys from our super
            let cur = super.dictionary
            for (key, value) in cur {
                d[key as! String] = value
            }
            // but we need to override contacts since the data is stored as NSData vs something we can use on the server side
            guard let contacts = self.contacts else {
                d[ScopeDataKeys.ContactsContacts.rawValue] = nil
                // no contacts? we're done.
                return d
            }
            // otherwise get the contacts in our format and upload it
            var contactsDictionary = [ContactsServerDataFormat]()
            for contact in contacts {
                contactsDictionary.append(contact.inServerDataFormat)
            }
            d[ScopeDataKeys.ContactsContacts.rawValue] = contactsDictionary
            return d
        }
    }
    
    public var contacts: Set<CopperContact>? {
        get {
            guard let availableContacts = self.data[ScopeDataKeys.ContactsContacts.rawValue] as? ContactBackingData else {
                return nil
            }
            // construct our set from the backing data
            var contactsSet: Set<CopperContact> = Set()
            for (identifier, backingData) in availableContacts {
                guard let idint32 = Int32(identifier) else {
                    continue
                }
                let contact = CopperContact.fromContactBackingDataValuesFormat(idint32, backingData: backingData)
                contactsSet.insert(contact)
            }
            return contactsSet
        }
        set {
            var backingData:ContactBackingData = Dictionary()
            guard let availableContacts = newValue else {
                self.data[ScopeDataKeys.ContactsContacts.rawValue] = backingData
                return
            }
            for contact in availableContacts {
                backingData[String(contact.identifier)] = contact.toContactBackingDataValuesFormat()
            }
            self.data[ScopeDataKeys.ContactsContacts.rawValue] = backingData
            
            self.uploaded = false
        }
    }
    
    public convenience init() {
        self.init(scope: C29Scope.ContactsFavorites, id: "current")
    }

    public convenience init(contacts: Set<CopperContact>, id: String = "current", verified: Bool = false) {
        self.init(scope: C29Scope.ContactsFavorites, data: nil, id: id, verified: verified)
        self.contacts = contacts
    }
    
    public override var isBlank: Bool {
        if let contacts = contacts {
            return contacts.count == 0
        }
        return true
    }
    
    // returns true if the cobject conforms to all requirements of its Type
    public override var valid: Bool {
        get {
            return !isBlank
        }
    }
    
    override func rehydrateDataIfNeeded(session: C29SessionDataSource?, completion: ((record: CopperRecordObject?) -> ())!) {
        // TODO make use of picture_url 
        completion?(record: self)
    }
    
    
    public static func getContactsWithPictureURLs(session: C29SessionDataSource, contacts: Set<CopperContact>, callback: (contacts: Set<CopperContact>)->()) {
        let group = dispatch_group_create()
        var contactsWithPictures = Set<CopperContact>()

        for var contact in Array(contacts) {
            dispatch_group_enter(group)
            if contact.pictureURL == nil && contact.picture != nil {
                guard let imageData = UIImagePNGRepresentation(contact.picture!) else {
                    contactsWithPictures.insert(contact)
                    dispatch_group_leave(group)
                    continue
                }
                // OK, let's send it
                // TODO this should queue requests after some number, like 3
                // vs sending them all at once in parallel
                dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    session.sessionCoordinator?.createByteFromFile("contact_\(contact.identifier)", data: imageData, callback: { bytes, error in
                        if let bytes = bytes as? C29Bytes {
                            contact.pictureURL = bytes.url
                            contactsWithPictures.insert(contact)
                        }
                        // TODO better error handling... currently fire and forget
                        dispatch_group_leave(group)
                    })
                })
            } else {
                contactsWithPictures.insert(contact)
                dispatch_group_leave(group)
            }
        }
        
        
        dispatch_group_notify(group, dispatch_get_main_queue(), {
            callback(contacts: contactsWithPictures)
        })
    }
}

extension CopperContactsRecord : CopperStringDisplayRecord {
    public var displayString: String {
        get {
            var count = "0"
            if let contacts = contacts {
                count = "\(contacts.count)"
            }
            return "\(count)/\(CopperContactsFavoritesLimit)"
        }
    }
}


func ==(lhs: CopperContactsRecord, rhs: CopperContactsRecord) -> Bool {
    return false
    // TODO fix me
}
