//
//  C29Networking.swift
//  CopperKit
//
//  Created by Doug Williams on 4/14/16.
//  Copyright © 2016 Doug Williams. All rights reserved.
//

import Foundation

//public typealias C29APICallback = ((AnyObject?, NSError?) -> ())

public typealias C29APIResultCallback = ((result: C29APIResult<NSHTTPURLResponse, NSDictionary?, NSError>)->())
public enum C29APIResult<R, D, E> {
    case Success(R, D)
    case Error(E)
}

@objc public protocol C29API:class {
    var delegate: CopperNetworkAPIDelegate? { get set }
    var dataSource:CopperNetworkAPIDataSource? { get set }
    var URL: String { get set }
}

@objc public protocol CopperNetworkAPIDelegate:class {
    func authTokenForAPI(api: CopperNetworkAPI) -> String?
    func userIdentifierForLoggingErrorsInAPI(api: CopperNetworkAPI) -> AnyObject?
    func networkAPI(api: CopperNetworkAPI, recordAnalyticsEvent event:String, withParameters parameters:[String:AnyObject])
    func networkAPI(api: CopperNetworkAPI, attemptLoginWithCallback callback:(success:Bool, error:NSError?) -> ())
    func beganRequestInNetworkAPI(api: CopperNetworkAPI)
    func endedRequestInNetworkAPI(api: CopperNetworkAPI)
}

@objc public protocol CopperNetworkAPIDataSource:class {
    func recordCacheForNetworkAPI(api:CopperNetworkAPI) -> C29RecordCache
}

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

public enum C29APIMethod {
    case GET_JWT
    case GET_USERINFO
    case DIALOG_VERIFY
    case DIALOG_VERIFY_CODE
    case OAUTH_AUTHORIZE
    case GET_OAUTH_URL_FOR_CODE
    case GET_USER
    case DELETE_USER
    case SAVE_USER_INFO
    case DELETE_USER_INFO
    case SAVE_USER_RECORDS
    case GET_USER_RECORDS
    case DELETE_USER_RECORDS
    case SAVE_USER_APPLICATION_RECORDS
    case DELETE_USER_APPLICATION_RECORDS
    case GET_USER_DEVICES
    case GET_USER_DEVICE
    case DELETE_USER_DEVICE
    case UPDATE_USER_DEVICE
    case GET_USER_APPLICATIONS
    case GET_USER_APPLICATION
    case DELETE_USER_APPLICATION
    case GET_REQUEST
    case SET_REQUEST_GRANT
    case SET_REQUEST_ACKNOWLEDGED
    case CREATE_BYTES
}

public enum C29APIPath: String {
    case OauthAuthorize = "oauth/authorize"
    case OauthUserinfo = "oauth/userinfo"
    case OauthDialog = "oauth/dialog"
    case Users = "users"
    case Verify = "verify"
    case Applications = "applications"
    case UsersLogin = "users/login"
    case UsersGrant = "grant"
    case UsersRequests = "requests"
    case UsersRequestsAck = "ack"
    case UsersRecords = "records"
    case UserDevices = "devices"
    case Go = "go"
    case Bytes = "bytes"
}


    