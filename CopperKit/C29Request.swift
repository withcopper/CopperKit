//
//  Request.swift
//  Copper
//
//  Created by Doug Williams on 12/18/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import UIKit

public class C29Request: NSObject, NSCoding, C29RequestDataSource, C29RequestCaller {
    
    class var Expiry: Int {
        return 300 // 5 min in seconds
    }
    
    class var ScopeSeparatorString: String {
        return ","
    }
    
    public enum Key: String {
        case UserId = "user_id"
        case RequestId = "request_id"
        case Timestamp = "timestamp"
        case ApplicationId = "application_id"
        case ScopesString = "scopes"
        case Scope = "scope"
        case Status = "status"
        case Platform = "platform"
        
        // Application Values -- these should likely be in their own object, or sent
        // as a separate JSON, along side the request, in time
        case ApplicationName = "application_name"
        case ApplicationColor = "application_color"
        case ApplicationLogoUri = "logo_uri"
    }
    
    enum RequestURLParameters: String {
        case Path = "request"
        case IdQueryParameter = "id"
    }

    public var userId: String
    public var id: String
    public var timestamp: NSDate
    public var applicationId: String
    public var scopesString: String?
    public var platform: C29RequestPlatform?
    
    // This should be set through sendResponse
    public var status: NSInteger = C29RequestStatus.Unanswered.rawValue
    
    // Note: we do not currently write these with the encoder
    public var records = [CopperRecord]()
    
    // to query if this was previously answered
    public var responded: Bool {
        return status != C29RequestStatus.Unanswered.rawValue
    }
    
    // Determines if a given request is timedout, per Request.Expiry
    public var expired: Bool {
        get {
            let diff = NSDate().timeIntervalSinceDate(self.timestamp)
            return diff > NSTimeInterval(C29Request.Expiry)
        }
    }
    
    // Returns all valid records included as part of this request
    public var complete: Bool {
        get {
            var completed = [CopperRecord]()
            for scope in scopes {
                for record in records {
                    if record.scope == scope && record.valid {
                        completed.append(record)
                        break
                    }
                }
            }
            return (completed.count == scopes.count)
        }
    }
    
    public func getApplication(session: C29SessionDataSource) -> C29CopperworksApplication? {
        return session.applicationCache.getApplication(applicationId) as? C29CopperworksApplication
    }
    
    init(userId: String, requestId: String, timestamp: Double, applicationId: String, scopesString: String! = nil, platform: C29RequestPlatform! = nil, status: NSInteger) {
        self.userId = userId
        self.id = requestId
        self.timestamp = NSDate(timeIntervalSince1970: timestamp)
        self.applicationId = applicationId
        self.scopesString = scopesString
        self.status = status
        self.platform = platform
        super.init()
    }
    
    public convenience init(requestData: C29RequestDataSource) {
        self.init(userId: requestData.userId, requestId: requestData.id, timestamp: requestData.timestamp.timeIntervalSince1970, applicationId: requestData.applicationId, scopesString: requestData.scopesString, platform: requestData.platform, status: requestData.status)
    }

    public required init?(coder decoder: NSCoder) {
        self.userId = decoder.decodeObjectForKey(Key.UserId.rawValue) as! String
        self.id = decoder.decodeObjectForKey(Key.RequestId.rawValue) as! String
        self.timestamp = decoder.decodeObjectForKey(Key.Timestamp.rawValue) as! NSDate
        self.applicationId = decoder.decodeObjectForKey(Key.ApplicationId.rawValue) as! String
        self.scopesString = decoder.decodeObjectForKey(Key.ScopesString.rawValue) as? String
        self.platform = decoder.decodeObjectForKey(Key.Platform.rawValue) as? C29RequestPlatform
        if let rawValue = decoder.decodeObjectForKey(Key.Status.rawValue) as? Int,
            _ = C29RequestStatus(rawValue: rawValue) {
            self.status = rawValue
        } else {
            self.status = C29RequestStatus.Unanswered.rawValue
        }
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(userId, forKey: Key.UserId.rawValue)
        coder.encodeObject(id, forKey: Key.RequestId.rawValue)
        coder.encodeObject(timestamp, forKey: Key.Timestamp.rawValue)
        coder.encodeObject(applicationId, forKey: Key.ApplicationId.rawValue)
        coder.encodeObject(scopesString, forKey: Key.ScopesString.rawValue)
        coder.encodeObject(platform, forKey: Key.Platform.rawValue)
        coder.encodeObject(status, forKey: Key.Status.rawValue)
    }
    
    public class func fromDictionary(dataDict: NSDictionary) -> (request: C29Request?, error: NSError?) {
        var error = Error?()
        
        guard let _ = C29CopperworksApplication.fromDictionary(dataDict) else {
            error = Error.Application
            return(nil, Error.Application.nserror)
        }
        
        if let requestId: String = dataDict[Key.RequestId.rawValue] as? String,
            userId :String = dataDict[Key.UserId.rawValue] as? String,
            timestamp :Double = dataDict[Key.Timestamp.rawValue] as? Double,
            applicationId :String = dataDict[Key.ApplicationId.rawValue] as? String,
            scopesString = dataDict[Key.Scope.rawValue] as? String {

                // Note: C29RequestScopeable will strip any non-valid scopes from the list when displaying
                // we don't pre-process and leave them here in case we eventually support these scopes
                
                // Build our platform, if available
                var platform = C29RequestPlatform?()
                if let platformDataDict = dataDict[Key.Platform.rawValue] as? [String:String] {
                    if let type = platformDataDict[C29RequestPlatform.Key.Type.rawValue] as String?,
                        version = platformDataDict[C29RequestPlatform.Key.Version.rawValue] as String? {
                            platform = C29RequestPlatform(type: type, version: version)
                    }
                }

                // Gather our status, if available
                var status = C29RequestStatus.DefaultStatus.rawValue
                if let statusRaw = dataDict[Key.Status.rawValue] as? Int,
                    let _ = C29RequestStatus(rawValue: statusRaw) {
                    status = statusRaw
                }
                
                // Server side timestamps are stored in ms, so % 1000
                return (C29Request(userId: userId, requestId: requestId, timestamp: (timestamp / 1000), applicationId: applicationId, scopesString: scopesString, platform: platform, status: status), nil)
        } else {
            // It's bad news if we get here. It means we are sending invalid/illformated requests
            error = Error.Parameter
        }
        C29LogWithRemote(.Error, error: error!.nserror, infoDict: dataDict as! [String : AnyObject])
        return (nil, error!.nserror)
    }
    
    public class func fromRequestURL(url: NSURL) -> (requestId: String?, error: NSError?) {
        // expected format: copper://request?id={XYZ} or http://open.withcopper.com/request?id={XYZ}
        var error: Error?
        if let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true) {
            // TODO we could/should test for the correct path, but since NSUrlComponents
            // treats the 'request' for copper://request as the host, it makes it difficult
            // for the same flow of code to verify both. Since our URL schemes are easy, now
            // we'll put that off for later
            // TODO this is shitty! \/\/\/\/\/\/\/
            if let host = components.host where C29Utils.CopperURLs.contains(host) || "request" == host {
                if let requestId = components.getQueryStringParameter(RequestURLParameters.IdQueryParameter.rawValue) {
                    return (requestId, nil)
                } else {
                    error = Error.Parameter
                }
            } else {
                error = Error.Host
            }
        } else {
            error = Error.InvalidURL
        }
        C29LogWithRemote(.Error, error: error!.nserror, infoDict: ["url":url])
        return (nil, error!.nserror)
    }
    
    public class func fromPushNotification(notification: [NSObject:AnyObject]) -> (requestId: String?, error: NSError?) {
        if let requestId: String = notification[C29Request.Key.RequestId.rawValue] as? String {
            // currently unused:
            // let alertText: String? =  notification["aps"]?.valueForKey("alert") as? String
            return (requestId, nil)
        }
        let error = Error.InvalidPush
        C29LogWithRemote(.Error, error: error.nserror)
        return (nil, error.nserror)
    }

    public class func getRequest(session: C29SessionDataSource, requestId: String, callback: C29RequestCallback) {
        // TODO should we check the requeststack to see if this request is already stored locally... ?
        session.sessionCoordinator?.getRequest(requestId, callback: { request in
                callback(request: request)
        })
    }

    // Write our request status to Firebase for the server listener... this can and should get smarter, and will likely get obviated by a native API when we roll off firebase support
    // This is a hacky way to flag for the server that a request has been submitted
    public func sendResponse(session: C29SessionDataSource, status: C29RequestStatus, callback: (success: Bool, redirecting: Bool)->()) {
        if (status == C29RequestStatus.Approved) {
            // we expect all requests to be Approved will be complete if we are going to send it
            assert(self.complete)
        }

        // Update (or build) a Application object
        guard let app = session.applicationCache.getApplication(applicationId) as? C29CopperworksApplication else {
            C29Log(.Warning, "Unable to send. Application is expected to be in the cache before we send a response. This is an expected warning for Fake Requests.")
            callback(success: false, redirecting: false)
            return
        }
        app.updateRecords(records)
        
        // Make our API calls to send the response
        session.sessionCoordinator?.setRequestGrant(self, status: status, records: records, forceRecordUpload: false) { (requestGrant: C29RequestGrant?) -> () in
            if let requestGrant = requestGrant {
                // Will overwrite any existing application of the same id, hence updateRecords is important above!
                session.applicationCache.push(app)
                if let redirectUri = requestGrant.redirectUri {
                    // TODO do we need to inspect self.platform?.type == .Mobile before redirecting
                    callback(success: true, redirecting: true)
                    if !UIApplication.sharedApplication().openURL(NSURL(string: redirectUri)!) {
                        C29Log(.Error, "We tried but were not able to redirect to \(app.name).")
                    }
                } else {
                    callback(success: true, redirecting: false)
                }
            } else {
                callback(success: false, redirecting: false)
            }
            
            
            
        }
    }
    
    public func setAck(session: C29SessionDataSource) {
        session.sessionCoordinator?.setRequestAck(self)
    }

}

extension C29Request: C29RequestScopeable {
    // Returns an array of Scopes that specify the parameters for this Request
    public var scopes: [C29Scope] {
        get {
            var c: [C29Scope] = Array()
            if let parsed = self.scopesString?.componentsSeparatedByString(C29Request.ScopeSeparatorString) {
                // ensure all scopes are real
                for found in parsed {
                    if let scope = C29Scope.fromString(found) {
                        c.append(scope)
                    }
                }
            }
            return c.sort({ $0.rawValue < $1.rawValue })
        }
    }
}


public class C29RequestPlatform: NSObject, NSCoding {
    
    // How the API passes this data back and forth, also used for NSCoding
    enum Key: String {
        case Type = "type"
        case Version = "version"
    }
    
    // Possible values
    enum Type: String {
        case Desktop = "desktop"
        case iOS = "ios"
        case Mobile = "android"
        case Unknown = "unknown"
    }
    
    var type: Type!
    var version: String?
    
    public init(type: String, version: String) {
        if let t = Type(rawValue: type) {
            self.type = t
        } else {
            self.type = Type.Unknown
        }
        self.version = version
    }
    
    required public init?(coder decoder: NSCoder) {
        self.type = .Unknown
        if let typeRawValue = decoder.decodeObjectForKey(C29RequestPlatform.Key.Type.rawValue) as? String,
            type = Type(rawValue: typeRawValue) {
            self.type = type
        }
        self.version = decoder.decodeObjectForKey(Key.Version.rawValue) as? String
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(type.rawValue, forKey: C29RequestPlatform.Key.Type.rawValue)
        coder.encodeObject(version, forKey: Key.Version.rawValue)
    }
}


public class C29RequestGrant: NSObject {
    // How the API passes this data back and forth, also used for NSCoding
    enum Key: String {
        case ApplicationId = "application_id"
        case Status = "status"
        case RequestId = "request_id"
        case RedirectUri = "redirect_uri"
    }
    
    var applicationId: String!
    var status: C29RequestStatus!
    var requestId: String!
    var redirectUri: String?
    
    init(applicationId: String, status: Int, requestId: String, redirectUri: String! = nil) {
        self.applicationId = applicationId
        self.requestId = requestId
        if let s = C29RequestStatus(rawValue: status) {
            self.status = s
        } else {
            self.status = C29RequestStatus.Unanswered // TODO is this the right default value? Unclear when this will actualy be set, but we have to have to set it to something since this is a required parameters
        }
        self.redirectUri = redirectUri
    }
    
    public class func fromDictionary(dataDict: NSDictionary) -> C29RequestGrant? {
        if let requestId: String = dataDict[Key.RequestId.rawValue] as? String,
            applicationId: String = dataDict[Key.ApplicationId.rawValue] as? String,
            status: Int = dataDict[Key.Status.rawValue] as? Int {
            // handle optionals below this line
            let redirectUri = dataDict[Key.RedirectUri.rawValue] as? String
            return C29RequestGrant(applicationId: applicationId, status: status, requestId: requestId, redirectUri: redirectUri)
        }
        return C29RequestGrant?()
    }
}

extension C29Request {
    public enum Error: Int {
        case InvalidURL = 0
        case InvalidPush = 1
        case Host = 2
        case Application = 3
        case Parameter = 4
        
        case Invalid = 55
        case Duplicate = 56
        case Expired = 57
        
        public var reason: String {
            switch self {
            case InvalidURL:
                return "Not a valid Copper Request URL"
            case InvalidPush:
                return "Not a valid Copper Request Push"
            case Host:
                return "Not a valid Copper Host URL"
            case Parameter:
                return "Invalid parameters"
            case Application:
                return "Invalid Copperworks Application parameters -- missing required applcation fields"
            case Expired:
                return "That request expired"
            case Duplicate:
                return "You've answered that already."
            case Invalid:
                return "We don't recognize that request"
            }
        }
        
        public var description: String {
            switch self {
            case Expired:
                return "Try sending yourself the request again."
            case Duplicate:
                return "Try sending yourself the request again."
            case Invalid:
                return "Try sending yourself the request again."
            default:
                return self.reason
            }
        }
        
        public var nserror: NSError {
            return NSError(domain: self.domain, code: self.rawValue, userInfo: [NSLocalizedFailureReasonErrorKey: self.reason])
        }
        
        var domain: String {
            return "\(NSBundle.mainBundle().bundleIdentifier!).C29Request"
        }
    }
}