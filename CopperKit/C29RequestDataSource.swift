//
//  C29RequestDataSource.swift
//  Copper
//
//  Created by Doug Williams on 3/23/2016.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import Foundation

// MARK: - Copper Request Objects
@objc public protocol C29RequestDataSource: class {
    var userId: String { get }
    var id: String  { get }
    var applicationId: String { get }
    var expired: Bool { get }
    var timestamp: NSDate { get }
    var scopesString: String? { get }
    var platform: C29RequestPlatform? { get }
    var status: NSInteger { get }
    var responded: Bool { get }
    var complete: Bool { get }
    var records: [CopperRecord] { get set }
}

public protocol C29RequestCaller {
    func getApplication(session: C29SessionDataSource) -> C29CopperworksApplication?
    static func getRequest(session: C29SessionDataSource, requestId: String, callback: C29RequestCallback)
    func sendResponse(session: C29SessionDataSource, status: C29RequestStatus, callback: C29RequestResponseCallback)
    func setAck(session: C29SessionDataSource)
}

public protocol C29RequestScopeable: class {
    var scopes: [C29Scope] { get }
}

@objc public enum C29RequestStatus: NSInteger {
    case Approved = 1
    case Dismissed = 0
    case Reported = -1
    case Unanswered = -29
    var localizedString:String {
        get {
            switch (self) {
            case Approved:
                return "Approved"
            case Dismissed:
                return "Dismissed"
            case Reported:
                return "Reported"
            case Unanswered:
                return "Unanswered"
            }
        }
    }
    static var DefaultStatus: C29RequestStatus {
        return Unanswered
    }
}

public typealias C29RequestCallback = (request: C29RequestDataSource?) -> ()
public typealias C29RequestResponseCallback = (success: Bool, redirecting: Bool) -> ()
