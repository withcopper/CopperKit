//
//  C29TouchAndHoldButton.swift
//  CopperKit
//
//  Created by Doug Williams on 5/9/16.
//  Copyright © 2016 Doug Williams. All rights reserved.
//

import Foundation

public class C29TouchAndHoldButton: UIButton {
    
    private var holdTimer: NSTimer?
    private var timeInterval: NSTimeInterval!
    private weak var target: AnyObject!
    private var action: Selector!
    
    public func addTarget(target: AnyObject, action: Selector, timeInterval: NSTimeInterval) {
        self.target = target
        self.action = action
        self.timeInterval = timeInterval
        self.addTarget(self, action: #selector(C29TouchAndHoldButton.sourceTouchUp(_:)), forControlEvents: .TouchUpInside)
        self.addTarget(self, action: #selector(C29TouchAndHoldButton.sourceTouchUp(_:)), forControlEvents: .TouchUpOutside)
        self.addTarget(self, action: #selector(C29TouchAndHoldButton.sourceTouchDown(_:)), forControlEvents: .TouchDown)
    }
    
    public func sourceTouchUp(sender: UIButton) {
        if holdTimer != nil {
            holdTimer!.invalidate()
            holdTimer = nil
        }
    }
    
    public func sourceTouchDown(sender: UIButton) {
        holdTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: target, selector: action, userInfo: nil, repeats: true)
    }
}