//
//  CopperEmailRecord.swift
//  Cobject Representation of an email address
//
//  Created by Doug Williams on 6/2/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import UIKit

public class CopperEmailRecord: CopperRecordObject, CopperEmail {

    override public var isBlank:Bool {
        return address == nil || address == ""
    }

    public var address: String? {
        get {
            if let addr = self.data[ScopeDataKeys.EmailAddress.rawValue] as? String {
                return addr
            }
            return String?()
        }
        set {
            if let new = newValue?.clean() where !new.isEmpty {
                self.data[ScopeDataKeys.EmailAddress.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.EmailAddress.rawValue)
            }
            self.uploaded = false
        }
    }
    
    let pattern = "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
    
    public convenience init(address: String! = nil, id: String = "current", verified: Bool = false) {
        self.init(scope: C29Scope.Email, data: nil, id: id, verified: verified)
        self.address = address
    }

    // returns true if the cobject conforms to all requirements of its Type
    public override var valid: Bool {
        
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: self.pattern, options: .CaseInsensitive)
        } catch _ {
            regex = nil
        }
        
        // This stringByTrimming.. String extension in Utils
        if let text = self.address?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {

            let range = NSMakeRange(0, text.characters.count)
            if let matchRange = regex?.rangeOfFirstMatchInString(text, options: .ReportProgress, range: range) {
                return matchRange.location != NSNotFound
            }

        }
        return false
    }

}

extension CopperEmailRecord : CopperStringDisplayRecord {
    
    public var displayString: String {
        get {
            if let address = address {
                return address
            }
            return ""
        }
    }
    
}

func ==(lhs: CopperEmailRecord, rhs: CopperEmailRecord) -> Bool {
    if lhs.id == rhs.id {
        return true
    }
    return lhs.address == rhs.address
}