//
//  CopperKitEntryControlView.swift
//  CopperKit
//
//  Created by Doug Williams on 5/12/16.
//  Copyright © 2016 Doug Williams. All rights reserved.
//

import Foundation

class CopperKitEntryControlView: UIView {
    
    var label: UILabel?
    var borderWidth: CGFloat = 1
    var bottomBorder: UIView?
    
    func setup() {
        label = UILabel()
        label!.minimumScaleFactor = 0.5
        label!.lineBreakMode = .ByTruncatingMiddle
        label!.translatesAutoresizingMaskIntoConstraints = false
        label!.textAlignment = NSTextAlignment.Center
        let downsize = self.frame.size.height * 0.10
        self.addSubview(label!)
        let widthConstraint = NSLayoutConstraint(item: label!, attribute: .Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0)
        addConstraint(widthConstraint)
        let heightConstraint = NSLayoutConstraint(item: label!, attribute: .Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: .Height, multiplier: 1.0, constant: downsize)
        addConstraint(heightConstraint)
        let centerXConstraint = NSLayoutConstraint(item: label!, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
        addConstraint(centerXConstraint)
        let centerYConstraint = NSLayoutConstraint(item: label!, attribute: .CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: downsize/2)
        addConstraint(centerYConstraint)
        bottomBorder = self.addBorder(edges: .Bottom, color: UIColor.copper_black40(), thickness: borderWidth).first
        self.backgroundColor = UIColor.clearColor()
        reset()
    }
    
    func reset() {
        self.label?.text = ""
    }
    
    func set(string: String) {
        self.label?.attributedText = C29Text.h2(string, color: UIColor.copper_black92())
    }
}