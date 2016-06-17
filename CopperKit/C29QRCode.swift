//
//  C29QRCode.swift
//  Copper
//
//  Created by Doug Williams on 10/7/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import Foundation

public class C29QRCode {
    
    enum Key: String {
        case Code = "code"
        case URL = "url"
    }
    
    // returns true if the URL is in the correct format
    // callback is there to provide a facility to react to the success/error with the API request
    // TODO this should probably be converted into a class that looks more like C29OAuth.swift
    public class func handleQRCodeURL(url: NSURL, session: C29SessionDataSource, callback: (success: Bool, error: NSError?)->()) {
        // example: https://open.withcopper.com/go?code=<code>
        var error = Error?()
        if let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true),
            let host = components.host {
                switch host {
                case "open.withcopper.com", "open-staging.withcopper.com", "api-staging.withcopper.com", "api.withcopper.com":
                    if url.path == "/go" {
                        if let code = components.getQueryStringParameter(C29QRCode.Key.Code.rawValue) {
                            session.sessionCoordinator?.getURLforCode(code, callback: { (url: NSURL?, error: NSError?) -> () in
                                if let url = url {
                                    C29OAuth.handleURL(url, session: session, callback: callback)
                                } else {
                                    callback(success: false, error: error)
                                }
                            })
                            return
                        } else {
                            error = C29QRCode.Error.Code
                        }
                    } else {
                        error = C29QRCode.Error.Path
                    }
                default:
                    error = C29QRCode.Error.Host
                }
        } else {
            error = .Invalid
        }
        
        if error != nil {
            C29LogWithRemote(.Warning, error: error!.nserror, infoDict: ["url":url])
            callback(success: false, error: error!.nserror)
        }
    }

    public class func fromDictionary(dataDict: NSDictionary) -> NSURL? {
        if let url = dataDict[Key.URL.rawValue] as? String {
            return NSURL(string: url)
        }
        C29LogWithRemote(.Warning, error: Error.InvalidFormat.nserror, infoDict: dataDict as! [String : AnyObject])
        return NSURL?()
    }
}

extension C29QRCode {
    enum Error: Int {
        case Invalid = 0
        case Host = 1
        case Path = 2
        case Code = 3
        case InvalidFormat = 4
        
        var reason: String {
            switch self {
            case Invalid:
                return "Not a Copper QR Code URL"
            case Host:
                return "Not a valid QR Code URL = check your path"
            case Path:
                return "Not a valid QR Code URL - check your path"
            case Code:
                return "Not a valid QR Code"
            case InvalidFormat:
                return "C29QRCode fromDictionary failed because some required data was omitted or in the wrong format"
            }
        }
        var nserror: NSError {
            return NSError(domain: self.domain, code: self.rawValue, userInfo: [NSLocalizedFailureReasonErrorKey: self.reason])
        }
        var domain: String {
            return "\(NSBundle.mainBundle().bundleIdentifier!).C29QRCode"
        }
    }
}