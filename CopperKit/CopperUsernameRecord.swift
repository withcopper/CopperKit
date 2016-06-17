//
//  CopperUsernameRecord.swift
//  CopperRecordObject Representation of a name
//
//  Created by Doug Williams on 1/7/15.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import Foundation

public class CopperUsernameRecord: CopperRecordObject, CopperUsername {

    public var username: String? {
        get {
            if let u = self.data[ScopeDataKeys.Username.rawValue] as? String {
                return u
            }
            return String?()
        }
        set {
            if let new = newValue?.clean() where !new.isEmpty {
                self.data[ScopeDataKeys.Username.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.Username.rawValue)
            }
            self.uploaded = false
        }
    }

    public convenience init(username: String! = nil, id: String = "current", verified: Bool = false) {
        self.init(scope: C29Scope.Username, data: nil, id: id, verified: verified)
        self.username = username
    }

    // returns true if the cobject conforms to all requirements of its Type
    public override var valid: Bool {
        return username != nil
    }
}


extension CopperUsernameRecord : CopperStringDisplayRecord {
    public var displayString: String {
        get {
            return username ?? ""
        }
    }
}

func ==(lhs: CopperUsernameRecord, rhs: CopperUsernameRecord) -> Bool {
    if lhs.id == rhs.id {
        return true
    }
    return lhs.username == rhs.username
}