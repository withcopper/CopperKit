//
//  CopperAPI.swift
//  Copper
//
//  Doug Williams on 12/9/14.
//

import Foundation
import SystemConfiguration

@objc public class CopperNetworkAPIRequest: NSObject {
    public let method: C29APIMethod
    public let callback: C29APIResultCallback
    public let url: NSURL
    public let httpMethod: HTTPMethod
    public var params = [String:AnyObject]?()
    public var authentication = false
    public var retries = 3
    
    public init(method: C29APIMethod, httpMethod: HTTPMethod, url: NSURL, authentication: Bool = false, params: [String:AnyObject]! = nil, callback: C29APIResultCallback) {
        self.method = method
        self.httpMethod = httpMethod
        self.url = url
        self.authentication = authentication
        self.params = params
        self.callback = callback
    }
}

public class CopperNetworkAPI: NSObject, C29API {
    
    public weak var delegate: CopperNetworkAPIDelegate?
    public weak var dataSource:CopperNetworkAPIDataSource?
    public var URL: String = "https://api.withcopper.com"

    var authToken:String? {
        get {
            return delegate?.authTokenForAPI(self)
        }
    }
    
    // Instance Variables
    var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    // Our workhorse method, though you shouldn't need to call this directly.
    public func makeHTTPRequest(apiRequest: CopperNetworkAPIRequest) {
        C29Log(.Debug, "CopperAPI >> HTTP \(apiRequest.httpMethod.rawValue) \(apiRequest.url)")
        
        guard Reachability.isConnectedToNetwork() else {
            dispatch_async(dispatch_get_main_queue()) {
                apiRequest.callback(result: .Error(C29NetworkAPIError.Disconnected.nserror))
            }
            return ()
        }
        
        // Request setup
        let request = NSMutableURLRequest(URL: apiRequest.url)
        request.HTTPMethod = apiRequest.httpMethod.rawValue
        
        // Handle authenticaiton requirements and reauth as necessary
        if apiRequest.authentication {
            // If we have our authToken, proceed
            if let token = self.authToken {
                self.addAuthorizationHeader(request, token: token)
            // If there are authentication retries left, then let's use them
            } else if apiRequest.retries > 0 {
                attemptLoginThenRetryHTTPRequest(apiRequest)
                return
                // No retries left and we're still unauthed
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    C29LogWithRemote(.Error, error: C29NetworkAPIError.Auth.nserror, infoDict: apiRequest.params)
                    apiRequest.callback(result: .Error(C29NetworkAPIError.Auth.nserror))
                    return
                }
            }
        }

        // Add any parameters to the request body as necessary
        if let params = apiRequest.params {
            do {
                self.addContentTypeHeader(request)
                let json = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
                request.HTTPBody = json
                if let json = NSString(data: json, encoding: NSUTF8StringEncoding) {
                    C29Log(.Debug, "CopperNetworkAPI request body '\(json)'")
                }
            } catch {
                let error = C29NetworkAPIError.JsonInvalid.nserror
                C29LogWithRemote(.Error, error: error, infoDict: apiRequest.params)
                dispatch_async(dispatch_get_main_queue()) {
                    apiRequest.callback(result: .Error(error))
                }
            }
        }
        
        // Make the call!
        delegate?.beganRequestInNetworkAPI(self)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.delegate?.endedRequestInNetworkAPI(self)
            // attempt to serialize the data from json which we expect
            var dataDict = NSDictionary?()
            if let data = data {
                do {
                    dataDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
                } catch {
                    // no op
                }
            }
            
            // handle our request on the main thread since it may affect UI downstream
            dispatch_async(dispatch_get_main_queue()) {
                // exit early with any network / system error
                guard error == nil else {
                    apiRequest.callback(result: .Error(error!))
                    return ()
                }
            
                // otherwise attempt to parse our response
                if let httpResponse = response as? NSHTTPURLResponse {
                    // We want to automatically retry if retries are available... and we're not attempted a JWT refresh already :)
                    if httpResponse.statusCode == 401 && apiRequest.retries > 0 && apiRequest.method != .GET_JWT && apiRequest.method != .DIALOG_VERIFY_CODE {
                        self.attemptLoginThenRetryHTTPRequest(apiRequest)
                        return
                    }
                    apiRequest.callback(result: .Success(httpResponse, dataDict))
                }
            }
        }
        task.resume()
    }
    
    func addAuthorizationHeader(request: NSMutableURLRequest, token: String) {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    func addContentTypeHeader(request: NSMutableURLRequest) {
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    }
    
    private func attemptLoginThenRetryHTTPRequest(apiRequest: CopperNetworkAPIRequest) {
        C29Log(.Debug, "CopperAPI >> attemping C29User.login with \(apiRequest.retries) retries")
        apiRequest.retries = apiRequest.retries-1
        delegate!.networkAPI(self, attemptLoginWithCallback: { (success, error) -> () in
            if success {
                self.makeHTTPRequest(apiRequest)
            } else {
                C29Log(.Debug, "CopperAPI >> error retrieving authToken")
                dispatch_async(dispatch_get_main_queue()) {
                    apiRequest.callback(result: .Error(error!))
                }
            }
        })
    }

}

public class Reachability {
    
    // credit: http://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647
    public class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
    
}


public enum C29NetworkAPIError: Int {
    case Disconnected = 0
    case Auth = 1
    case JsonInvalid = 3
    case CopperAPIDown = 4
    case HTTPStatusCode = 5
    
    var reason: String {
        switch self {
        case Disconnected:
            return "Your device appears to be disconnected from the Internet."
        case Auth:
            return "You are no longer authenticated with Copper. For security, we need you to be authenticated before we can complete this request. You may need to restart the app to fix this error."
        //case UserConflict:
        //    return "This user id was previously registered."
        case JsonInvalid:
            return "We were unable to process that request."
        case CopperAPIDown:
            return "Copper is down"
        case HTTPStatusCode:
            return "Unexpected HTTP Status code"
        }
    }
    var description: String {
        switch self {
        case .CopperAPIDown:
            return "Check @withcopper for our status. Otherwise, please try again soon."
        default:
            return self.reason
        }
    }
    public var nserror: NSError {
        return NSError(domain: self.domain, code: self.rawValue, userInfo: ["message": self.reason, NSLocalizedFailureReasonErrorKey: self.reason])
    }
    var domain: String {
        return "\(NSBundle.mainBundle().bundleIdentifier!).CopperNetworkAPI"
    }
}