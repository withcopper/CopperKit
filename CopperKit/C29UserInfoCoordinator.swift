//
//  C29UserInfoCoordinator
//  Copper
//
//  Created by Doug Williams on 3/3/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

public class C29UserInfoCoordinator {
    
    private let application: C29Application!
    private let networkAPI = CopperNetworkAPI()

    internal var userInfo: C29UserInfo?
    internal var sessionId: String!
    
    var jwt: String?
    
    init(application: C29Application) {
        self.application = application
        self.networkAPI.delegate = self
        self.sessionId = C29Utils.getGUID()
    }
    
    // Attempt to get a userInfo object with a response URL
    func getUserInfo(withResponseURL url: NSURL, application: C29Application, callback: ((userInfo: C29UserInfo?, error: NSError?)->())! = nil) {
        let components = NSURLComponents(string: url.absoluteString)
        guard let jwt = components?.getQueryStringParameter("access_token") else {
            C29LogWithRemote(.Error, error: Error.MissingAccessTokenFound.nserror)
            callback(userInfo: nil, error: Error.MissingAccessTokenFound.nserror)
            return
        }
        self.jwt = jwt
        // 1. get the userId
        guard let userId = C29UserInfo.getUserId(withJWT: jwt) else {
            C29LogWithRemote(.Error, error: C29UserInfo.Error.JWTDecodeError.nserror)
            callback(userInfo: nil, error: C29UserInfo.Error.JWTDecodeError.nserror)
            return
        }
        self.getUserInfo(userId, callback: {(userInfo: C29UserInfo?, error: NSError?) in
            callback?(userInfo: userInfo, error: error)
        })
    }
    
    
    func getUserInfo(userId: String, callback: ((userInfo: C29UserInfo?, error: NSError?)->())! = nil) {
        if userInfo == nil {
            userInfo = C29UserInfo(userId: userId, records: nil)
        }
        let url = NSURL(string: "\(networkAPI.URL)/\(C29APIPath.OauthUserinfo.rawValue)")!
        let request = CopperNetworkAPIRequest(method: .GET_USERINFO,
                                              httpMethod: .GET,
                                              url: url,
                                              authentication: true,
                                              params: nil,
                                              callback: { (result: C29APIResult) in
                                                switch result {
                                                case let .Error(error):
                                                    callback(userInfo: nil, error: error)
                                                case let .Success(response, dataDict):
                                                    guard response.statusCode == 200 else {
                                                        callback(userInfo: nil, error: Error.InvalidHTTPResponseCode.nserror)
                                                        return
                                                    }
                                                    guard let dataDict = dataDict else {
                                                        callback(userInfo: nil, error: Error.RecordsDictInvalidFormat.nserror)
                                                        return
                                                    }
                                                    self.userInfo?.fromDictionary(dataDict, callback: { (newUserInfo: C29UserInfo?, error: NSError?) in
                                                        self.userInfo = newUserInfo
                                                        callback?(userInfo: self.userInfo, error: error)
                                                    })
                                                    
                                                }
        })
        networkAPI.makeHTTPRequest(request)
    }
    
    func refreshUserInfo(userId: String, callback: ((userInfo: C29UserInfo?, error: NSError?)->())! = nil) {
        self.getUserInfo(userId, callback: {(userInfo: C29UserInfo?, error: NSError?) in
            self.userInfo = userInfo
            callback?(userInfo: userInfo, error: error)
        })
    }

    func userInfoFromVerificationResult(result: C29VerificationResult) {
        self.userInfo = C29UserInfo.fromVerificationResult(result)
    }
    
    public func getPermittedScopes() -> [C29Scope]? {
        return userInfo?.getPermittedScopes()
    }
    
    public func allScopesArePermitted(scopes: [C29Scope]! = nil) -> Bool {
        guard let scopes = scopes else {
            return true
        }
        if let permitted = getPermittedScopes() {
            for scope in scopes {
                if !permitted.contains(scope) {
                    return false
                }
            }
            return true
        }
        return false
    }

}

extension C29UserInfoCoordinator: CopperNetworkAPIDelegate {
    
    @objc public func authTokenForAPI(api: CopperNetworkAPI) -> String? {
        return self.jwt ?? self.application.jwt // fallback
    }
    
    @objc public func userIdentifierForLoggingErrorsInAPI(api: CopperNetworkAPI) -> AnyObject? {
        return self.application.userId
    }
    
    @objc public func networkAPI(api: CopperNetworkAPI, recordAnalyticsEvent event: String, withParameters parameters: [String : AnyObject]) {
        C29LogWithRemote(.Error, error: Error.HTTPError.nserror, infoDict: parameters)
    }
    
    @objc public func networkAPI(api: CopperNetworkAPI, attemptLoginWithCallback callback: (success: Bool, error: NSError?) -> ()) {
        C29LogWithRemote(.Error, error: Error.Non20XAPIError.nserror, infoDict: nil)
        callback(success: false, error: Error.Non20XAPIError.nserror)
        // If we get here, it likely means our access token was invalid or expired
        // TODO we should use it to get a refresh token
    }
    
    @objc public func beganRequestInNetworkAPI(api: CopperNetworkAPI) {
        CopperNetworkActivityRegistry.sharedRegistry.activityBegan()
    }
    
    @objc public func endedRequestInNetworkAPI(api: CopperNetworkAPI) {
        CopperNetworkActivityRegistry.sharedRegistry.activityEnded()
    }
    
}

extension C29UserInfoCoordinator {
    
    public enum Error: Int {
        case HTTPError = 900
        case MissingAccessTokenFound = 1
        case Non20XAPIError = 2
        case ApplicationIdNotSet = 3
        case RecordsDictInvalidFormat = 4
        case AuthError = 5
        case InvalidHTTPResponseCode = 6
        case InvalidConfiguration = 7
        
        public var reason: String {
            switch self {
            case .HTTPError:
                return "There was an unexpected HTTP response"
            case .MissingAccessTokenFound:
                return "There was no access token found in the login url."
            case .Non20XAPIError:
                return "The API returned a non-20X response unexpectedly."
            case .ApplicationIdNotSet:
                return "Copperworks Application Id is not set and attemptLogin() will always fail. You must call CUApplication.setApplication(\"<appId>\"), where <appId> is your application's ID found on Copperworks @ withcopper.com/apps"
            case .RecordsDictInvalidFormat:
                return "The API returned data in an invalid format"
            case .AuthError:
                return "The API returned an auth error -- jwt is potentially expired -- TODO implement better handling"
            case .InvalidHTTPResponseCode:
                return "How embarassing. We recieved an unexpected error from the server."
            case .InvalidConfiguration:
                    return "Missing configuration items needed to continue, e.g. JWT and user ID settings. You are likely calling this out of logical order."
            }
        }
        var description: String {
            switch self {
            case .MissingAccessTokenFound:
                return "We expect a valid access token in the access_token query param"
            default:
                return self.reason
            }
        }
        var nserror: NSError {
            return NSError(domain: self.domain, code: self.rawValue, userInfo: [NSLocalizedFailureReasonErrorKey: self.reason])
        }
        var domain: String {
            return "\(NSBundle.mainBundle().bundleIdentifier!).C29Coordinator"
        }
    }

}