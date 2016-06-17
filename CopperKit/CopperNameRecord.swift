//
//  CopperNameRecord.swift
//  CopperRecordObject Representation of a name
//
//  Created by Doug Williams on 6/2/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import Foundation

public class CopperNameRecord: CopperRecordObject, CopperName {

    public var firstName: String? {
        get {
            if let n = self.data[ScopeDataKeys.NameFirstName.rawValue] as? String {
                return n
            }
            return String?()
        }
        set {
            if let new = newValue where !new.isEmpty {
                self.data[ScopeDataKeys.NameFirstName.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.NameFirstName.rawValue)
            }
            self.uploaded = false
        }
    }
    
    public var lastName: String? {
        get {
            if let n = self.data[ScopeDataKeys.NameLastName.rawValue] as? String {
                return n
            }
            return String?()
        }
        set {
            if let new = newValue where !new.isEmpty {
                self.data[ScopeDataKeys.NameLastName.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.NameLastName.rawValue)
            }
            self.uploaded = false
        }
    }
    
    public var fullName: String? {
        guard !isBlank else { return nil }
        return "\(self.firstName ?? "") \(self.lastName ?? "")".clean()
    }
    
    public var initials: String? {
        guard !isBlank else { return nil }
        let first: String? = firstName?.characters.count > 0 ? firstName?[0] : String?() // substring extension from CopperKit
        let second: String?  = lastName?.characters.count > 0 ? lastName?[0] : String?() // substring extension from CopperKit
        return "\(first ?? "")\(second ?? "")".uppercaseString
    }

    public convenience init(firstName: String! = nil, lastName: String! = nil, id: String = "current", verified: Bool = false) {
        self.init(scope: C29Scope.Name, data: nil, id: id, verified: verified)
        self.firstName = firstName
        self.lastName = lastName
    }

    // returns true if the cobject conforms to all requirements of its Type
    public override var valid: Bool {
        return !(firstName == nil && lastName == nil)
    }
}


extension CopperNameRecord : CopperStringDisplayRecord {
    public var displayString: String {
        get {
            var name = ""
            if let firstName = firstName {
                name = firstName
            }
            if let lastName = lastName {
                if name.isEmpty {
                    name = lastName
                } else {
                    name += " \(lastName)"
                }
            }
            return name
        }
    }
}

func ==(lhs: CopperNameRecord, rhs: CopperNameRecord) -> Bool {
    if lhs.id == rhs.id {
        return true
    }
    return lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName
}