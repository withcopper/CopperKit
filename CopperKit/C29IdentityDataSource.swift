//
//  C29AppIdentityDataSource.swift
//  Copper
//
//  Created by Benjamin Sandofsky on 8/13/15.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import Foundation

@objc public protocol C29IdentityDataSource: class {
    
    // Multi Record Types
    var picture: CopperPicture? { get set }
    var name: CopperName? { get set }
    var address: CopperAddress? { get set }
    var email: CopperEmail? { get set }
    var phone: CopperPhone? { get set }
    var username:CopperUsername? { get set }
    var birthday: CopperDate? { get set }
    var signature: CopperSignature? { get set }
    
    // Set Records
    // CopperContacts isn't OBJC compliant, commenting it out since we're not focused on contact rn
    //var contactsFavorites: CopperContacts { get set }
    
    // Record operations
    func getDefaultOrBlank(scope: C29Scope) -> CopperRecord?
    func addOrUpdateRecord(record: CopperRecord)
    func removeRecord(record: CopperRecord)
    func sync(record: [CopperRecord])
    func save(forceUpload: Bool, callback: C29SuccessCallback)
    func reload()
}