//
//  CopperAddressBookProxy.swift
//  Copper
//
//  Created by Benjamin Sandofsky on 11/11/15.
//  Copyright © 2015 Copper Technologies, Inc. All rights reserved.
//

import UIKit
import AddressBook

public struct CopperAddressBookEntryProxy:ContactQueryable {
    var contact:ABRecordRef
    public func getID() -> Int32? {
        let recordId = ABRecordGetRecordID(contact)
        guard recordId != kABRecordInvalidID else {
            return nil
        }
        return recordId
    }
    public func getName() -> String? {
        guard let name = ABRecordCopyCompositeName(contact) else {
            return nil
        }
        return name.takeRetainedValue() as String
    }
    public func getEmails() -> [String] {
        if let emailAddresses: ABMultiValueRef = ABRecordCopyValue(contact, kABPersonEmailProperty)?.takeRetainedValue() {
            var email_addresses = [String]()
            for index in 0 ..< ABMultiValueGetCount(emailAddresses) {
                if let email = ABMultiValueCopyValueAtIndex(emailAddresses, index)?.takeRetainedValue() as? String {
                    email_addresses.append(email)
                }
            }
            return email_addresses
        } else {
            return []
        }
    }
    public func getPhoneNumbers() -> [String] {
        if let phoneNumbers: ABMultiValueRef = ABRecordCopyValue(contact, kABPersonPhoneProperty)?.takeRetainedValue() {
            var phone_numbers = [String]()
            for index in 0 ..< ABMultiValueGetCount(phoneNumbers) {
                if let number = ABMultiValueCopyValueAtIndex(phoneNumbers, index)?.takeRetainedValue() as? String {
                    phone_numbers.append(number)
                }
            }
            return phone_numbers
        } else {
            return []
        }
    }
    public func getPicture() -> UIImage? {
        if !ABPersonHasImageData(contact) {
            return UIImage?()
        }
        let data = ABPersonCopyImageDataWithFormat(contact, kABPersonImageFormatThumbnail).takeRetainedValue()
        let imageData = UIImage(data: data)
        return imageData
    }
}

public struct CopperAddressBookProxy: ContactSource {
    private var addressBookRef: ABAddressBook
    public init() {
        addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    }
    public var permissionStatus:ContactSourcePermissionState {
        switch ABAddressBookGetAuthorizationStatus() {
        case .Authorized:
            return .Authorized
        case .Denied:
            return .Denied
        case .Restricted:
            return .Restricted
        case .NotDetermined:
            return .NotDetermined
        }
    }

    public func requestPermission(requestBlock:ContactsRequestBlock){
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                requestBlock(granted:granted, error:error)
            }
        }
    }

    public func enumerateOverQueriables(block: ContactQueryEnumerationBlock) {
        for entry in self {
            block(entry)
        }
    }
}

extension CopperAddressBookProxy:SequenceType  {
    public typealias Generator = AnyGenerator<CopperAddressBookEntryProxy>
    public func generate() -> Generator {
        var index = 0
        let allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as [ABRecordRef]
        return AnyGenerator { () -> CopperAddressBookEntryProxy? in
            if index < allContacts.count {
                index += 1
                return CopperAddressBookEntryProxy(contact:allContacts[index])
            }
            return nil
        }
    }
}