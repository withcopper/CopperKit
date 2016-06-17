//
//  Cß29CopperworksApplication.swift
//  Copper
//
//  Created by Doug Williams on 5/8/15.
//  Copyright (c) 2015 Doug Williams. All rights reserved.
//

import Foundation

public class C29CopperworksApplication: NSObject, NSCoding, C29CopperworksApplicationDataSource {

    // NSCoding lookups
    enum Key: String {
        case ApplicationId = "application_id"
        case Name = "application_name"
        case Logo = "logo_uri"
        case URL = "application_url" // TODO not sure if correct
        case Records = "records"
        case Color = "accent_color"
        case RedirectURI = "redirect_uri"
    }

    public var id: String
    public var records = [CopperRecord]()
    public var name: String
    public var logoUri: String?
    public var color: UIColor?
    public var url: String?
    public var redirectUri: String?
    
    public init(applicationId: String, name: String, records: [CopperRecord]) {
        self.id = applicationId
        self.name = name
        self.records = records
        super.init()
    }
    
    // MARK: - NSCoding
    
    required convenience public init?(coder decoder: NSCoder) {
        let applicationId = decoder.decodeObjectForKey(Key.ApplicationId.rawValue) as! String
        let name = decoder.decodeObjectForKey(Key.Name.rawValue) as! String
        let records = decoder.decodeObjectForKey(Key.Records.rawValue) as! [CopperRecord]
        self.init(applicationId: applicationId, name: name, records: records)
        self.logoUri = decoder.decodeObjectForKey(Key.Logo.rawValue) as? String
        self.url = decoder.decodeObjectForKey(Key.URL.rawValue) as? String
        self.color = decoder.decodeObjectForKey(Key.Color.rawValue) as? UIColor
        self.redirectUri = decoder.decodeObjectForKey(Key.RedirectURI.rawValue) as? String
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(id, forKey: Key.ApplicationId.rawValue)
        coder.encodeObject(name, forKey: Key.Name.rawValue)
        coder.encodeObject(records, forKey: Key.Records.rawValue)
        coder.encodeObject(logoUri, forKey: Key.Logo.rawValue)
        coder.encodeObject(color, forKey: Key.Color.rawValue)
        coder.encodeObject(url, forKey: Key.URL.rawValue)
        coder.encodeObject(redirectUri, forKey: Key.RedirectURI.rawValue)
    }

    public class func fromDictionary(dataDict: NSDictionary) -> C29CopperworksApplication? {
        C29Log(.Debug, "Application.fromDictionary with dataDict \(dataDict)")
        var data = dataDict
        if let client =  dataDict["client"] as? NSDictionary{
            data = client
        }
        if let applicationId = data[Key.ApplicationId.rawValue] as? String,
            let name = data[Key.Name.rawValue] as? String {
            let records = [CopperRecord]()
// TODO fix this when we decide how we want to use it again
//            if let recordsDict = dataDict[Key.Records.rawValue] as? [String:String] {
//                //  format we expect in data: ["scope" : "recordid"]
//                for (scopeString, _) in recordsDict {
////                    if let scope = C29Scope.fromString(scopeString),
////                        let record = session.recordCache.getRecord(scope) {
////                        records.append(record)
////                    } else {
////                        if let scope = C29Scope.fromString(scopeString) {
////                            records.append(scope.createRecord() as! CopperRecord)
////                        }
////                    }
//                }
//            }
            
            let app = C29CopperworksApplication(applicationId: applicationId, name: name, records: records)
            // optional, nice to have values
            app.logoUri = data[Key.Logo.rawValue] as? String
            app.url = data[Key.URL.rawValue] as? String
            app.redirectUri = data[Key.RedirectURI.rawValue] as? String
            if let colorRaw = data[Key.Color.rawValue] as? String {
                app.color = UIColor.hexStringToUIColor(colorRaw)
            }
            return app
        } else {
            // we are receiving Application json of an unexpected format
            C29LogWithRemote(.Error, error: Error.InvalidFormat.nserror, infoDict: dataDict as! [String : AnyObject])
            return C29CopperworksApplication?()
        }
    }
    
    // expected dataDict format is {{deviceid,name,timestamp},{deviceid,...}}"
    public class func getApplicationsFromDictionary(dataDict: [NSDictionary]) -> [C29CopperworksApplication]? {
        var applications = [C29CopperworksApplication]()
        for applicationsDict in dataDict {
            if let application = C29CopperworksApplication.fromDictionary(applicationsDict) {
                applications.append(application)
            } else {
                C29LogWithRemote(.Error, error: Error.InvalidFormat.nserror, infoDict: applicationsDict as! [String : AnyObject])
                return nil
            }
        }
        return applications
    }
    
    // update (or add) a particular Scope to this token
    func updateRecords(updates: [CopperRecord]) {
        for update in updates {
            // This will serve as a flag if an update was made
            var updated = false
            // 1. Walk through the application and update the record of each Scope, if found
            // ... intentionally attempt to maintain the order of records in the clients
            for index in records.indices {
                if records[index].scope == update.scope {
                    records[index] = update
                    updated = true
                    break
                }
            }
            // 2. If an update wasn't made, we simply add it
            if !updated {
                self.records.append(update)
            }
        }
    }
}

extension C29CopperworksApplication {
    enum Error: Int {
        case InvalidFormat = 1
        
        var reason: String {
            switch self {
            case InvalidFormat:
                return "C29CopperworksApplication fromDictionary failed because some required data was omitted or in the wrong format"
            }
        }
        var nserror: NSError {
            return NSError(domain: self.domain, code: self.rawValue, userInfo: [NSLocalizedFailureReasonErrorKey: self.reason])
        }
        var domain: String {
            return "\(NSBundle.mainBundle().bundleIdentifier!).C29CopperworksApplication"
        }
    }
}