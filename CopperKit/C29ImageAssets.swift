//
//  C29ImageAssets.swift
//  CopperKit
//
//  Created by Doug Williams on 11/20/15.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation


enum C29ImageAssets: String {
    // Icons
    case IconClose = "copperkit-icon-close"
    case IconBackspace = "copperkit-icon-backspace"

    // Login Card
    case LoginCheckbox = "copperkit-login-checkbox"
    case LoginCancelled = "copperkit-login-cancelled"
    
    var image: UIImage {
        switch self {
        default:
            return UIImage(named: self.rawValue, inBundle: CopperKitBundle, compatibleWithTraitCollection: nil)! // we're OK with the bang here, because it simply means we're missing the file in the assets folder, or there's a mismatch between rawValue and actual filenames! Runtime errors, easy to fix.
        }
    }
}