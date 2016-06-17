//
//  Verification.swift
//  Copper
//
//  Created by Doug Williams on 5/29/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import Foundation

public let C29VerificationCodeExpiry: NSTimeInterval = 120.0

public class C29VerificationCode: NSObject {
    
    enum Key: String {
        case Code = "code"
        case Digits = "digits"
        case Timestamp = "timestamp"
    }
    
    public var code: String
    public var digits: String?
    public var timestamp: NSDate?
    
    public var expires: NSDate? {
        get {
            guard let timestamp = timestamp else {
                return nil
            }
            return timestamp.dateByAddingTimeInterval(C29VerificationCodeExpiry)
        }
    }
    
    public var expired: Bool {
        get {
            guard let timestamp = timestamp else {
                return false
            }
            return (timestamp.timeIntervalSince1970 < NSDate().timeIntervalSince1970 - C29VerificationCodeExpiry)
        }
    }
    
    public init(code: String, digits: String! = nil, timestamp: NSDate! = nil) {
        self.code = code
        self.digits = digits
        self.timestamp = timestamp
    }
    
    public var dictionary: NSDictionary {
        get {
            var d = [String: AnyObject]()
            d[Key.Code.rawValue] = self.code
            d[Key.Digits.rawValue] = self.digits
            d[Key.Timestamp.rawValue] = self.timestamp?.timeIntervalSinceNow
            return d
        }
    }

    public class func fromDictionary(dataDict: NSDictionary) -> C29VerificationCode? {
        if let code = dataDict[Key.Code.rawValue] as? String {
            let verificationCode = C29VerificationCode(code: code)
            // As part of the Login flow, we get two optional pieces of data
            verificationCode.digits = dataDict[Key.Digits.rawValue] as? String
            if let timestamp  = dataDict[Key.Timestamp.rawValue] as? Int {
                verificationCode.timestamp = NSDate(timeIntervalSince1970: NSTimeInterval(timestamp))
            }
            return verificationCode
        }
        C29LogWithRemote(.Critical, error: C29VerificationError.InvalidFormat.nserror, infoDict: dataDict as! [String : AnyObject])
        return C29VerificationCode?()
    }
}

public class C29VerificationResult {
    
    enum Key: String {
        case UserId = "user_id"
        case Token = "token"
        case IsNewUser = "is_new_user"
        case DeviceId = "device_id"
    }
    
    public var userId: String
    public var token: String
    public var isNewUser: Bool
    public var deviceId: String
    public var secret: String?

    init(userId: String, token: String, isNewUser: Bool, deviceId: String) {
        self.userId = userId
        self.token = token
        self.isNewUser = isNewUser
        self.deviceId = deviceId
    }
    
    public class func fromDictionary(dataDict: NSDictionary) -> C29VerificationResult? {
        if let userId = dataDict[Key.UserId.rawValue] as? String,
            let token = dataDict[Key.Token.rawValue] as? String,
            let deviceId = dataDict[Key.DeviceId.rawValue] as? String,
            let isNewUser = dataDict[Key.IsNewUser.rawValue] as? Bool {
                return C29VerificationResult(userId: userId, token: token, isNewUser: isNewUser, deviceId: deviceId)
        }
        C29LogWithRemote(.Critical, error: C29VerificationError.InvalidFormat.nserror, infoDict: dataDict as! [String : AnyObject])
        return C29VerificationResult?()
    }
    
    public class func fromAPIResult(result: C29APIResult<NSHTTPURLResponse, NSDictionary?, NSError>, callback: (verificationResult: C29VerificationResult?, error: NSError?)->()) {
        switch result {
        case let .Error(error):
            callback(verificationResult: nil, error: error)
            return
        case let .Success(response, dataDict):
            switch response.statusCode {
            // Verification errors
            case 401:
                callback(verificationResult: nil, error: C29VerificationError.DialogCodeInvalid.nserror)
                return
            case 419:
                callback(verificationResult: nil, error: C29VerificationError.DialogCodeExpired.nserror)
                return
            case 429:
                callback(verificationResult: nil, error: C29VerificationError.DialogCodeLocked.nserror)
            return
            // Success
            case 200, 201:
                guard let dataDict = dataDict else {
                    callback(verificationResult: nil, error: C29VerificationError.DialogCodeMissing.nserror)
                    return
                }
                let verificationResult = C29VerificationResult.fromDictionary(dataDict)
                callback(verificationResult: verificationResult, error: nil)
            default:
                callback(verificationResult: nil, error: nil)
            }
        }
    }
}

public enum C29VerificationError: Int {
    case InvalidFormat = 1
    // Dialog errors
    case DialogCodeExpired = 227888
    case DialogCodeLocked = 237888
    case DialogCodeInvalid = 247888
    case DialogCodeMissing = 257888

    var reason: String {
        switch self {
        case InvalidFormat:
            return "C29Verification.fromDictionary failed because some required data was omitted or in the wrong format"
        case DialogCodeExpired:
            return "That code is expired. Try again."
        case DialogCodeLocked:
            return "That code is locked. Try again."
        case DialogCodeInvalid:
            return "Wrong code."
        case .DialogCodeMissing:
            return "Unexpected error"
        }
    }
    public var nserror: NSError {
        return NSError(domain: self.domain, code: self.rawValue, userInfo: [NSLocalizedFailureReasonErrorKey: self.reason])
    }
    var domain: String {
        return "\(NSBundle.mainBundle().bundleIdentifier!).Verification"
    }
}