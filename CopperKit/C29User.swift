//
//  C29User
//  Copper
//
//  Created by Doug Williams on 12/9/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import Foundation

public class C29User: NSObject, NSCoding {
    
    // Constant used to find this document in the filesystem; assumed unique
    public static var CacheFile: String = "C29User"
    static var FileType = FileSystemType.Documents
    
    @objc public enum Key: Int {
        case Id = 0
        case UserId = 1
        case ICloudToken = 2
        case LastRequestId = 3
        case Role = 4
        
        public var value: String {
            switch self {
            case .Id:
                return "id"
            case .UserId:
                return "user_id"
            case .ICloudToken:
                return "icould_token"
            case .LastRequestId:
                return "last_request_id"
            case .Role:
                return "role"
            }
        }
    }

    enum NSCodingKeys: String {
        case Data = "data"
        case UserDevices = "user_devices"
    }
    
    public enum Role: String {
        case Admin = "admin"
        case Developer = "developer"
        case User = "user"
        
        static var Default: Role {
            return Role.User
        }
    }
    
    // hold's a reference to this user's data NSDictionary
    var data = [String:AnyObject]()
    // holds an array of UserDevice objects for this user
    public var devices = [C29UserDevice]()
    // This will hold a timestamp for the last authentication, and enable a app-wide 1 mintue signin
    public var lastAuthenticationTimestamp : NSDate?
    public var session: C29SessionDataSource?
    
    public override init() {
        super.init()
    }
    
    // MARK: - NSCoding
    convenience required public init?(coder decoder: NSCoder) {
        self.init()
        self.data = decoder.decodeObjectForKey(NSCodingKeys.Data.rawValue) as! [String:AnyObject]
        if let devices = decoder.decodeObjectForKey(NSCodingKeys.UserDevices.rawValue) as? [C29UserDevice] {
            self.devices = devices
        }
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(data, forKey: NSCodingKeys.Data.rawValue)
        coder.encodeObject(devices, forKey: NSCodingKeys.UserDevices.rawValue)
    }
    
    public class func fromDictionary(dataDict: NSDictionary) -> C29User? {
        if let _ = dataDict[Key.UserId.value] as? String {
            let user = C29User()
            user.setValue(.Id, value: dataDict[Key.Id.value])
            user.setValue(.ICloudToken, value: dataDict[Key.ICloudToken.value])
            user.setValue(.LastRequestId, value: dataDict[Key.LastRequestId.value])
            user.setValue(.Role, value: dataDict[Key.Role.value])
            return user
        }
        C29LogWithRemote(.Critical, error: Error.InvalidFormat.nserror, infoDict: dataDict as! [String : AnyObject])
        return C29User?()
    }

    // MARK: User Info
    
    public func getValue(key: Key) -> AnyObject? {
        return data[key.value]
    }
    
    public func setValue(key: Key, value: AnyObject?) {
        if value == nil {
            data.removeValueForKey(key.value)
        } else {
            data.updateValue(value!, forKey: key.value)
        }
    }
    
    public func setUserInfo(user: C29User?) {
        if let user = user {
            self.setValue(Key.Id, value: user.getValue(Key.Id))
            self.setValue(Key.ICloudToken, value: user.getValue(Key.ICloudToken))
            self.setValue(Key.LastRequestId, value: user.getValue(Key.LastRequestId))
            self.setValue(Key.Role, value: user.getValue(Key.Role))
            if let session = session {
                self.save(session.appGroupIdentifier)
            }
        }
    }

    func addUserDevice(add: C29UserDevice) -> Bool {
        for device in self.devices {
            if add == device {
                return false
            }
        }
        devices.insert(add, atIndex: 0)
        return true
    }
    
    // use cautiously, this only updates the local copies --
    // use logoutOfUserDevice(..) to talk to the API, too...
    func removeUserDevice(deviceId: String) -> Bool {
        for device in self.devices {
            if device.id == deviceId {
                self.devices.removeObject(device)
                return true
            }
        }
        return false
    }
    
    public func getRole() -> Role {
        if let roleRawValue = self.getValue(C29User.Key.Role) as? String,
            let role = Role(rawValue: roleRawValue) {
                return role
        }
        return Role.Default
    }
    
    public func resetUserData() {
        self.data = [String:AnyObject]()
        self.devices = [C29UserDevice]()
        self.lastAuthenticationTimestamp = nil
    }
    
    public func load() -> Bool {
        if let session = session {
            return load(session.appGroupIdentifier)
        }
        return false
    }
    
    public func deleteFile() {
        if let session = session {
            deleteFile(session.appGroupIdentifier)
        }
    }
    
    public func save() {
        if let session = session {
            save(session.appGroupIdentifier)
        }
    }
}

extension C29User {
    enum Error: Int {
        case InvalidFormat = 3
        
        var reason: String {
            switch self {

            case .InvalidFormat:
                return "C29User.fromDictionary: failed because some required data was omitted or in the wrong format."
            }
        }
        var nserror: NSError {
            return NSError(domain: self.domain, code: self.rawValue, userInfo: [NSLocalizedFailureReasonErrorKey: self.reason])
        }
        var domain: String {
            return "\(NSBundle.mainBundle().bundleIdentifier!).C29User"
        }
    }
}

extension C29User:FileSaveable {
    
}

extension C29User:FileLoadable {
    func set(user: C29User) {
        self.data = user.data
        self.devices = user.devices
    }
}
