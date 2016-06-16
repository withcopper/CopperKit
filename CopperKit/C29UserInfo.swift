//
//  C29UserInfo
//  Copper
//
//  Created by Doug Williams on 3/8/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

public class C29UserInfo: NSObject {
    
    public var records: [C29Scope: CopperRecord]!
    
    // MARK: User Id
    
    public var userId: String!
    
    // MARK: Address
    
    public var streetOne: String? {
        return (records[.Address] as? CopperAddress)?.streetOne
    }
    public var streetTwo: String? {
        return (records[.Address] as? CopperAddress)?.streetTwo
    }
    public var city: String? {
        return (records[.Address] as? CopperAddress)?.city
    }
    public var state: String? {
        return (records[.Address] as? CopperAddress)?.state
    }
    public var zip: String? {
        return (records[.Address] as? CopperAddress)?.zip
    }
    public var country: String? {
        return (records[.Address] as? CopperAddress)?.country
    }
    
    // MARK: Name
    
    public var firstName: String? {
        return (records[.Name] as? CopperName)?.firstName
    }
    
    public var lastName: String? {
        return (records[.Name] as? CopperName)?.lastName
    }
    
    public var fullName: String {
        return (records[.Name] as? CopperName)?.fullName ?? ""
    }
    
    // MARK: Email
    
    public var emailAddress: String? {
        return (records[.Email] as? CopperEmail)?.address
    }
    
    // MARK: Phone Number
    
    public var phoneNumber: String? {
        return (records[.Phone] as? CopperPhone)?.phoneNumber
    }
    
    // MARK: Picture
    
    public var picture: UIImage? {
        return (records[.Picture] as? CopperPicture)?.image
    }
    
    public var pictureURL: NSURL? {
        get {
            guard let u = (records[.Picture] as? CopperPicture)?.url else {
                return nil
            }
            return NSURL(string: u)
        }
    }
    
    // MARK: Username
    
    public var username: String? {
        return (records[.Username] as? CopperUsername)?.username
    }
    
    init(userId: String, records: [C29Scope: CopperRecord]! = nil) {
        self.userId = userId
        self.records = records ?? [C29Scope: CopperRecord]()
    }
    
    class func fromVerificationResult(result: C29VerificationResult) -> C29UserInfo {
        return C29UserInfo(userId: result.userId)
    }
    
    func fromDictionary(dataDict: NSDictionary?, callback: (userInfo: C29UserInfo?, error: NSError?)->()) {

        guard let dataDict = dataDict else {
            callback(userInfo: nil, error: Error.DataDictEmpty.nserror)
            return
        }
        
        let group = dispatch_group_create()
        // print(dataDict)
        for scopeDict in dataDict {
            guard let scopeRaw = scopeDict.key as? String,
                let scope = C29Scope.fromString(scopeRaw) else {
                    C29LogWithRemote(.Error, error: Error.UserInfoInvalidScope.nserror, infoDict: ["scopeRaw":scopeDict.key])
                    break
            }
            
            guard let recordDict = scopeDict.value as? NSDictionary else {
                C29LogWithRemote(.Debug, error: Error.UserInfoNilData.nserror, infoDict: dataDict as! [String : AnyObject])
                continue
            }
            
            dispatch_group_enter(group)
            CopperRecordObject.fromDictionary(scope, dataDict: recordDict, session: nil, completion: { (record: CopperRecordObject?) in
                guard let record = record else {
                    C29LogWithRemote(.Debug, error: Error.UserInfoInvalidFormat.nserror, infoDict: dataDict as! [String : AnyObject])
                    dispatch_group_leave(group)
                    return
                }
                // TODO rehyrdation of ContactsFavorites is suspected to be currently broken it nullifis all of the current records. So we're shortcuricuting it here.
                record.uploaded = true
                self.records.updateValue(record, forKey: record.scope)
                dispatch_group_leave(group)
            })
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), {
            callback(userInfo: self, error: nil)
        })
    }
    
    // returns the records for the scopes, nil if any requested scope is not available
    func getRecords(forScopes scopes: [C29Scope]?) -> [C29Scope: CopperRecord]? {
        guard let scopes = scopes else { return [C29Scope: CopperRecord]() }
        var recordsForScopes = [C29Scope: CopperRecord]()
        for scope in scopes {
            if let record = self.records[scope] {
                recordsForScopes.updateValue(record, forKey: scope)
            } else {
                // TODO we could return an error here
                return nil
            }
        }
        return recordsForScopes
    }
    
    // returns true if this scope is verified
    public func isVerified(scope: C29Scope) -> Bool {
        return records[scope]?.verified ?? false
    }
    
    public func getPermittedScopes() -> [C29Scope]? {
        if records.count == 0 {
            return nil
        }
        return Array(records.keys)
    }
    
    class func getUserId(withJWT jwt: String) -> String? {
        // Parse the userId from the JWT
        do {
            let payload = try decodeJWT(jwt)
            // we expect the user id in userInfo dictionary as {d:{uid:...,...}}
            if let d = payload.body["d"] as? NSDictionary,
                let uid = d["uid"] as? String {
                    return uid
            } else {
                C29LogWithRemote(.Error, error: Error.JWTUserIdNotFound.nserror)
            }
        } catch {
            // no op
        }
        return String?()
    }

}

extension C29UserInfo {
    enum Error: Int {
        case DataDictEmpty = 7
        case UserInfoNilData = 8
        case UserInfoInvalidFormat = 9
        case UserInfoInvalidScope = 10
        case JWTDecodeError = 11
        case JWTUserIdNotFound = 12
        
        var reason: String {
            switch self {
            case .DataDictEmpty:
                return "There was no data returned within the userInfo dictionary"
            case .UserInfoNilData:
                return "UserInfo did not include data as expected"
            case .UserInfoInvalidFormat:
                return "UserInfo did not include all of the necessary data and came back nil"
            case .UserInfoInvalidScope:
                return "UserInfo Sync returned an unexpected scope type"
            case .JWTDecodeError:
                return "JWT decode failed - userId unknown"
            case .JWTUserIdNotFound:
                return "A user ID was not found in the Access Token as expected"
            }
        }
        var nserror: NSError {
            return NSError(domain: self.domain, code: self.rawValue, userInfo: [NSLocalizedFailureReasonErrorKey: self.reason])
        }
        var domain: String {
            return "\(NSBundle.mainBundle().bundleIdentifier!).C29UserInfo"
        }
    }
}