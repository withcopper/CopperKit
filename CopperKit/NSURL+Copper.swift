//
//  NSURL+Copper.swift
//  Copper
//
//  Created by Doug Williams on 10/1/15.
//  Copyright © 2015 Copper Technologies, Inc. All rights reserved.
//

import Foundation

extension NSURLComponents {
    
    public func getQueryStringParameter(name: String) -> String? {
        if let queryItems = queryItems as [NSURLQueryItem]? {
            return queryItems.filter({ (item) in item.name == name }).first?.value
        }
        return String?()
    }
    
}