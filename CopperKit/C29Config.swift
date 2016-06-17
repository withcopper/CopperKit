//
//  File.swift
//  CopperKit
//
//  Created by Doug Williams on 5/11/16.
//  Copyright © 2016 Doug Williams. All rights reserved.
//

import Foundation

class C29Config {
    // just need a stub
}

public var CopperKitBundle: NSBundle { // NSBundle(forClass: C29Config.self)
    get {
        let podBundle = NSBundle(forClass: C29Config.self)
        let bundleURL = podBundle.URLForResource("CopperKit", withExtension: "bundle")
        let bundle = NSBundle(URL: bundleURL!)
        return bundle!
    }
}
//public let CopperKitBundle = NSBundle(forClass: C29Config.self)

public var CopperKitVersion: String {
    let version = CopperKitBundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    let build = CopperKitBundle.objectForInfoDictionaryKey("CFBundleVersion") as! String
    return "\(version).\(build)"
}
