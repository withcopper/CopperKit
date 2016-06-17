//
//  C29Utils
//  Copper
//
//  Created by Doug Williams on 10/21/15.
//  Copyright © 2015 Copper Technologies, Inc. All rights reserved.
//

import Foundation
import CoreTelephony

public typealias C29SuccessCallback = (success: Bool)->()

public class C29Utils {

    // Generate a random GUID
    public class func getGUID() -> String {
        return NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    // Get the ISO country code (e.g. "US") for the device
    internal  class func getPhoneCountryCode(asNumber: Bool = false) -> String? {
        // this is an optional import so let's test for it before committing to it below
        guard objc_getClass("CTTelephonyNetworkInfo") != nil else {
            return nil
        }
        let networkInfo: CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
        if let carrier : CTCarrier = networkInfo.subscriberCellularProvider {
            return carrier.isoCountryCode!.uppercaseString
        }
        return String?()
    }
    
    
    public class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
        
        // usage:
        // delay(0.5) { // do stuff }
    }
    
    
    // Get the height of the status bar (http://stackoverflow.com/questions/12991935/how-to-programmatically-get-ios-status-bar-height/16598350#16598350)
    public class func getStatusBarHeight() -> CGFloat {
        let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
        return Swift.min(statusBarSize.width, statusBarSize.height)
    }
    
    public static var animationDuration: Double {
        return 0.35
    }
    
    internal static var CopperURLs: [String] = ["withcopper.com", "open.withcopper.com", "open-staging.withcopper.com", "api-staging.withcopper.com", "www-staging.withcopper.com", "download.withcopper.com"]

}