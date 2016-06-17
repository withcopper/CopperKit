//
//  ContactSource.swift
//  Copper
//
//  Created by Benjamin Sandofsky on 11/11/15.
//  Copyright © 2015 Copper Technologies, Inc. All rights reserved.
//

import Foundation

public protocol ContactQueryable {
    func getID() -> Int32?
    func getName() -> String?
    func getEmails() -> [String]
    func getPhoneNumbers() -> [String]
    func getPicture() -> UIImage?
}

public enum ContactSourcePermissionState {
    case NotDetermined
    case Restricted // Parental Controls
    case Denied
    case Authorized
}

public typealias ContactQueryEnumerationBlock = (ContactQueryable) -> ()
public typealias ContactsRequestBlock = (granted:Bool, error:CFError?) -> ()

public protocol ContactSource {
    var permissionStatus:ContactSourcePermissionState { get }
    func requestPermission(requestBlock:ContactsRequestBlock)
    func enumerateOverQueriables(block: ContactQueryEnumerationBlock)
}

public extension ContactSource {
    func generateContacts() -> Set<CopperContact> {
        var contacts:Set<CopperContact> = Set()
        self.enumerateOverQueriables { (queryable) -> () in
            guard let id = queryable.getID() else {
                return
            }
            let contact = CopperContact(identifier:id,
                fullName:queryable.getName() ?? "No name",
                emailAddresses: queryable.getEmails(),
                phoneNumbers: queryable.getPhoneNumbers(),
                picture: queryable.getPicture(),
                pictureURL: nil)
            guard contact.hasAnyContent else {
                return
            }
            contacts.insert(contact)
        }
        return contacts
    }
}