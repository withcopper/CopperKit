//
//  C29Records.swift
//  Copper
//
//  Created by Doug Williams on 3/22/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import UIKit

// MARK: - Copper Records

@objc public protocol CopperRecord: class {
    var scope: C29Scope { get }
    var id: String { get }
    var verified: Bool { get set }
    var valid: Bool { get }
    var dictionary: NSDictionary { get }
    var timestamp: NSDate? { get }
    var uploaded: Bool { get set }
    var deleted: Bool { get set }
    var isBlank:Bool { get }
}

func ==(lhs: CopperRecord, rhs: CopperRecord) -> Bool {
    return lhs.id == rhs.id
}

@objc public protocol CopperRecordObjectDelegate {
    func recordWasUpdated(record: CopperRecordObject, type: CopperRecord.Type)
}

@objc public protocol CopperStringDisplayRecord {
    var displayString:String { get }
}

public typealias CopperMultiRecord = protocol<CopperRecord>

@objc public protocol CopperSetRecord: CopperRecord {
}

@objc public protocol CopperEmail: CopperMultiRecord {
    var address:String? { get set }
}

@objc public protocol CopperAddress: CopperMultiRecord {
    var streetOne: String? { get set }
    var streetTwo: String? { get set }
    var city: String? { get set }
    var state: String? { get set }
    var zip: String? { get set }
    var country: String? { get set }
//    func fromPlace(place: GMSPlace) // commented out to remove dependency of Google Maps
}

@objc public protocol CopperPicture: CopperRecord {
    var image: UIImage? { get set }
    var url: String? { get set }
    func getPicture() -> UIImage?
}

@objc public protocol CopperName: CopperRecord {
    var firstName: String? { get set }
    var lastName: String? { get set }
    var fullName: String? { get }
    var initials: String? { get }
}

@objc public protocol CopperPhone: CopperMultiRecord {
    var phoneNumber: String? { get set } // the whole number: +14156130691
    var countryCode: String? { get set } // the country code: US
    var number: String? { get set } // the phone number 4156130691
    var countryImage: UIImage? { get } // flag of the country code
}

@objc public protocol CopperUsername: CopperRecord {
    var username: String? { get set }
}

@objc public protocol CopperDate: CopperRecord {
    var date: NSDate? { get set }
}

public protocol CopperContacts: CopperSetRecord {
    var contacts:Set<CopperContact>? { get set }
}

@objc public protocol CopperSignature: CopperRecord {
    var signatureImage: UIImage? { get set }
    // This is a hack, see comment in CopperSignatureRecord
    func getImage() -> UIImage?
}

