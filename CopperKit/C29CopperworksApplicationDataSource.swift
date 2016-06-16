//
//  C29CopperworksApplicationDataSource.swift
//  Copper
//
//  Created by Doug Williams on 3/7/16.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import Foundation

// MARK: - CopperWorks Application

@objc public protocol C29CopperworksApplicationDataSource: class {
    var id:String { get }
    var records:[CopperRecord] { get }
    var name:String { get }
    var logoUri:String? { get }
    var url:String? { get }
    var redirectUri:String? { get }
}