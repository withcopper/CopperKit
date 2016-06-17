//
//  C29AppSessionDataSource.swift
//  Copper
//
//  Created by Doug Williams on 3/22/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

public let C29SessionIdentityDidUpdateNotification = "C29SessionIdentityDidUpdateNotification"

@objc public protocol C29SessionDataSource {
    var userId: String? { get }
    var requestStack: C29RequestStack { get }
    var applicationCache: C29CopperworksApplicationCache { get }
    var recordCache: C29RecordCache { get }
    var imageCache: C29ImageCache { get }
    var user: C29User? { get }
    var sessionCoordinator: C29SessionCoordinator? { get }
    var appGroupIdentifier: String { get }
}

@objc public protocol C29SessionCoordinator {
    func saveUserRecords(records: [CopperRecordObject], callback: C29SuccessCallback)
    func deleteUserRecords(records: [CopperRecordObject], callback: C29SuccessCallback)
    func getRequest(requestId: String, callback: (C29Request?)->())
    func createByteFromFile(fileId: String, data: NSData, callback: (bytes: AnyObject?, error: NSError?)->())
    func setRequestGrant(request: C29Request, status: C29RequestStatus, records: [CopperRecord], forceRecordUpload: Bool, callback: (requestGrant: C29RequestGrant?)->())
    func setRequestAck(request: C29Request)
    func deleteUserApplication(application: C29CopperworksApplicationDataSource, callback: (success: Bool, error: NSError?)->())
    func getURLforCode(code: String, callback: (url: NSURL?, error: NSError?)->())
    func postUserVerification(verificationCode: C29VerificationCode, digits: String, callback: (verificationResult: AnyObject?, error: NSError?)->())
    func handleOAuthDialogURL(oauth: C29OAuth, callback: (request: C29Request?, error: NSError?)->())
}