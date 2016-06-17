//
//  CopperBirthdayRecord.swift
//  CopperRecordObject Representation of a name
//
//  Created by Doug Williams on 1/12/15.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import Foundation

public class CopperDateRecord: CopperRecordObject, CopperDate {
    
    let DateStringFormat = "yyyy-MM-dd"

    var dateString: String? {
        get {
            if let d = self.data[ScopeDataKeys.Date.rawValue] as? String {
                return d
            }
            return String?()
        }
        set {
            // TODO error checking for a valid date
            if let newValue = newValue {
                self.data[ScopeDataKeys.Date.rawValue] = newValue
            } else {
                self.data.removeValueForKey(ScopeDataKeys.Date.rawValue)
            }
            self.uploaded = false
        }
    }
    
    // convenience getter / setter
    public var date: NSDate? {
        get {
            guard let dateString = dateString else {
                return nil
            }
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = DateStringFormat
            return dateFormatter.dateFromString(dateString)
        }
        set {
            if let newValue = newValue {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = DateStringFormat
                self.dateString = dateFormatter.stringFromDate(newValue)
            } else {
                dateString = nil
            }
        }
    }

    public convenience init(dateString: String! = nil, id: String = "current", verified: Bool = false) {
        self.init(scope: C29Scope.Birthday, data: nil, id: id, verified: verified)
        self.dateString = dateString
    }

    // returns true if the cobject conforms to all requirements of its Type
    override public var valid: Bool {
        return date != nil
    }
    
}


extension CopperDateRecord: CopperStringDisplayRecord {
    public var displayString: String {
        get {
            if let date = date {
               let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MMMM dd, yyyy"
                return dateFormatter.stringFromDate(date)
            } else {
                return "Set your date 📅"
            }
        }
    }
}

func ==(lhs: CopperDateRecord, rhs: CopperDateRecord) -> Bool {
    if lhs.id == rhs.id {
        return true
    }
    return lhs.date == rhs.date
}