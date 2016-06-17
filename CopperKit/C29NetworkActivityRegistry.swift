//
//  CopperNetworkActivityRegistry.swift
//  Copper
//
//  Created by Doug Williams on 10/29/15.
//  Copyright © 2015 Copper Technologies, Inc. All rights reserved.
//

import UIKit

public let C29NetworkActivityBeganNotification = "C29NetworkActivityBeganNotification"
public let C29NetworkActivityEndedNotification = "C29NetworkActivityEndedNotification"

public protocol CopperNetworkActivityRegistryDelegate: class {
    func networkIndicatorShouldIndicate()
    func networkIndicatorShouldNotIndicate()
}

public class CopperNetworkActivityRegistry: NSObject {
    
    public var delegate: CopperNetworkActivityRegistryDelegate?
    
    private var _visibleNetworkActivityCalls = 0 {
        didSet(oldValue){
            guard oldValue != _visibleNetworkActivityCalls else {
                return
            }
            if(_visibleNetworkActivityCalls < 0) {
                C29Log(.Warning, "Network Activity Indicator was asked to hide more often than shown")
                _visibleNetworkActivityCalls = 0
            }
            if oldValue == 0 {
                handleStateChangeToStarted()
            } else if _visibleNetworkActivityCalls == 0 {
                handleStateChangeToEnded()
            }
        }
    }

    public func activityBegan() {
        dispatch_async(dispatch_get_main_queue()) {
            self._visibleNetworkActivityCalls = self._visibleNetworkActivityCalls + 1
        }
        
    }

    public func activityEnded() {
        dispatch_async(dispatch_get_main_queue()) {
            self._visibleNetworkActivityCalls = self._visibleNetworkActivityCalls - 1
        }
    }

    private func handleStateChangeToStarted() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        NSNotificationCenter.defaultCenter().postNotificationName(C29NetworkActivityBeganNotification, object: nil)
        delegate?.networkIndicatorShouldIndicate()
    }

    private func handleStateChangeToEnded() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        NSNotificationCenter.defaultCenter().postNotificationName(C29NetworkActivityEndedNotification, object: nil)
        delegate?.networkIndicatorShouldNotIndicate()
    }

    public static var sharedRegistry:CopperNetworkActivityRegistry {
        get {
            return _sharedRegistry
        }
    }
    
    private func updateNetworkActivityIndicator(){
        let visible = _visibleNetworkActivityCalls > 0
        UIApplication.sharedApplication().networkActivityIndicatorVisible = visible
    }
}

private let _sharedRegistry = CopperNetworkActivityRegistry()