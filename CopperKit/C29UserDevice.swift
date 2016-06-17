//
//  C29UserDevice
//  Copper
//
//  Created by Doug Williams on 12/1/15.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import Foundation

public class C29UserDevice: NSObject, NSCoding {
    
    public enum Key: String {
        case DeviceId = "device_id"
        case Timestamp = "created"
        case LastActive = "last_active"
        case Name = "name"
        case Type = "type"
        case Label = "label"
        case DeviceToken = "device_token"
        case PushEnabled = "push_enabled"
        case BundleId = "bundle_id"
    }
    
    public enum DeviceType: String {
        case Mobile = "mobile"
        case Desktop = "desktop"
        case Browser = "browser"
        case Chrome = "chrome"
        case Safari = "safari"
        case Other = "other"
    }
    
    public let id: String!
    public let timestamp: NSDate!
    public let name: String!
    public let type: DeviceType!
    public let lastActive: NSDate!
    public let label: String!
    public let pushEnabled: Bool!
    public let deviceToken: String?
    public let bundleId: String?

    init(id: String, timestamp: NSDate, name: String, lastActive: NSDate, type: DeviceType, label: String, pushEnabled: Bool = false, deviceToken: String! = nil, bundleId: String! = nil) {
        self.id = id
        self.timestamp = timestamp
        self.name = name
        self.lastActive = lastActive
        self.type = type
        self.label = label
        self.pushEnabled = pushEnabled
        self.deviceToken = deviceToken
        self.bundleId = bundleId
    }
    
    // MARK: - NSCoding
    convenience required public init?(coder decoder: NSCoder) {
        let id = decoder.decodeObjectForKey(Key.DeviceId.rawValue) as! String
        let timestamp = decoder.decodeObjectForKey(Key.Timestamp.rawValue) as! NSDate
        let name = decoder.decodeObjectForKey(Key.Name.rawValue) as! String
        let lastActive = decoder.decodeObjectForKey(Key.LastActive.rawValue) as? NSDate ?? NSDate()
        var type = DeviceType.Other
        if let typeRawValue = decoder.decodeObjectForKey(C29UserDevice.Key.Type.rawValue) as? String,
            let _type = DeviceType(rawValue: typeRawValue) {
            type = _type
        }
        let label = decoder.decodeObjectForKey(Key.Label.rawValue) as! String
        let pushEnabled = decoder.decodeObjectForKey(Key.PushEnabled.rawValue) as? Bool ?? false
        let deviceToken = decoder.decodeObjectForKey(Key.DeviceToken.rawValue) as? String
        let bundleId = decoder.decodeObjectForKey(Key.BundleId.rawValue) as? String
        
        self.init(id: id, timestamp: timestamp, name: name, lastActive: lastActive, type: type, label: label, pushEnabled: pushEnabled, deviceToken: deviceToken, bundleId: bundleId)
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(id, forKey: Key.DeviceId.rawValue)
        coder.encodeObject(timestamp, forKey: Key.Timestamp.rawValue)
        coder.encodeObject(name, forKey: Key.Name.rawValue)
        coder.encodeObject(lastActive, forKey: Key.LastActive.rawValue)
        coder.encodeObject(type?.rawValue, forKey: C29UserDevice.Key.Type.rawValue)
        coder.encodeObject(label, forKey: Key.Label.rawValue)
        coder.encodeObject(pushEnabled, forKey: Key.PushEnabled.rawValue)
        coder.encodeObject(deviceToken, forKey: Key.DeviceToken.rawValue)
        coder.encodeObject(bundleId, forKey: Key.BundleId.rawValue)
    }
    
    public class func fromDictionary(dataDict: NSDictionary) -> C29UserDevice? {
        if let id = dataDict[Key.DeviceId.rawValue] as? String,
            let createdTimestamp = dataDict[Key.Timestamp.rawValue] as? Double,
            let name = dataDict[Key.Name.rawValue] as? String,
            let label = dataDict[Key.Label.rawValue] as? String,
            let lastActiveTimestamp = dataDict[Key.LastActive.rawValue] as? Double,
            let typeRawValue = dataDict[C29UserDevice.Key.Type.rawValue] as? String {
                let timestamp = NSDate(timeIntervalSince1970: createdTimestamp)
                let lastActive = NSDate(timeIntervalSince1970: lastActiveTimestamp)
                let type = DeviceType(rawValue: typeRawValue) ?? .Other
                let pushEnabled = dataDict[Key.PushEnabled.rawValue] as? Bool ?? false
                let deviceToken = dataDict[Key.DeviceToken.rawValue] as? String
                let bundleId = dataDict[Key.BundleId.rawValue] as? String
            
            return C29UserDevice(id: id, timestamp: timestamp, name: name, lastActive: lastActive, type: type, label: label, pushEnabled: pushEnabled, deviceToken: deviceToken, bundleId: bundleId)
        } else {
            // we are receiving Application json of an unexpected format
            C29LogWithRemote(.Error, error: Error.InvalidFormat.nserror, infoDict: dataDict as! [String : AnyObject])
            return C29UserDevice?()
        }
    }
    
     // expected dataDict format is {{deviceid,name,timestamp},{deviceid,...}}"
    public class func getDevicesFromDictionary(dataDict: [NSDictionary]) -> [C29UserDevice]? {
        var devices = [C29UserDevice]()
        for deviceDict in dataDict {
            if let device = C29UserDevice.fromDictionary(deviceDict) {
                devices.append(device)
            } else {
                C29LogWithRemote(.Error, error: Error.InvalidFormat.nserror, infoDict: deviceDict as! [String : AnyObject])
                return nil
            }
        }
        return devices
    }
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? C29UserDevice {
            return rhs.id == self.id
        }
        return false
    }
}




extension C29UserDevice {
    enum Error: Int {
        case InvalidFormat = 1
        case DeleteUnsuccessful = 2

        var reason: String {
            switch self {
            case DeleteUnsuccessful:
                return "C29UserDevice delete failed unexpectedly"
            case InvalidFormat:
                return "C29UserDevice fromDictionary failed because some required data was omitted or in the wrong format"
            }
        }
        var nserror: NSError {
            return NSError(domain: self.domain, code: self.rawValue, userInfo: [NSLocalizedFailureReasonErrorKey: self.reason])
        }
        var domain: String {
            return "\(NSBundle.mainBundle().bundleIdentifier!).C29UserDevice"
        }
    }
}