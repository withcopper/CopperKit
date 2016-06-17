//
//  Utils.swift

//  Copper
//  Misc static procedures that make life easier elsewhere
//
//  Created by Doug Williams on 1/19/15.
//  Copyright (c) 2015 Doug Williams. All rights reserved.
//

// import Foundation
// import Crashlytics

public enum C29LogLevel:Int {
    
    case Emergency
    case Alert
    case Critical
    case Error
    case Warning
    case Notice
    case Info
    case Debug
    
    var nativeLogLevel:Int32 {
        get {
            // NOTE: values are from asl.h
            switch self {
            case .Emergency:
                return  0 // ASL_LEVEL_EMERG
            case .Alert:
                return 1 // ASL_LEVEL_ALERT
            case .Critical:
                return 2 // ASL_LEVEL_CRIT
            case .Error:
                return 3 // ASL_LEVEL_ERR
            case .Warning:
                return 4 // ASL_LEVEL_WARNING
            case .Notice:
                return 5 // ASL_LEVEL_NOTICE
            case .Info:
                return 6 //ASL_LEVEL_INFO
            case .Debug:
                return 7 // ASL_LEVEL_DEBUG
            }
        }
    }
    
    var localizedDescription:String {
        get {
            switch self {
            case .Debug:
                return "Debug"
            case .Info:
                return "Info"
            case .Notice:
                return "Notice"
            case .Warning:
                return "Warning😡"
            case .Error:
                return "Error⛔️"
            case .Critical:
                return "Critical💣"
            case .Alert:
                return "Alert🚨"
            case .Emergency:
                return "Emergency🔥"
            }
        }
    }
}


// Set this on a per build settting
#if DEBUG
    public var C29LoggerLevel: C29LogLevel = .Debug
#else
    public var C29LoggerLevel: C29LogLevel = .Info
#endif

public func StartCopperLoggingService() {
//    if objc_getClass("Crashlytics") != nil {
//        Crashlytics.startWithAPIKey("8c2f01da8be6effdb16fa335bdfb2a8995f7b46a")
//    }
}

public func C29LogWithRemote(level: C29LogLevel, error: NSError, infoDict: [String:AnyObject]! = nil) {
    
    C29Log(level, error.localizedDescription)
    
//    guard objc_getClass("Crashlytics") != nil else {
//        return
//    }
//    
//    Crashlytics.startWithAPIKey("8c2f01da8be6effdb16fa335bdfb2a8995f7b46a")
//    if level.rawValue <= C29LoggerLevel.rawValue {
//        if let infoDict = infoDict {
//            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: infoDict)
//        } else {
//            Crashlytics.sharedInstance().recordError(error)
//        }
//    }
}

public func C29Log(level: C29LogLevel, @autoclosure _ logStatement: () -> String) {
    if level.rawValue <= C29LoggerLevel.rawValue {
        // We'll move this to ASL logging later
        print("\(level.localizedDescription)\t\(logStatement())")
    }
}
