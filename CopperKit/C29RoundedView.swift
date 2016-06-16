//
//  C29RoundedView.swift
//  CopperKit
//
//  Created by Doug Williams on 5/9/16.
//  Copyright © 2016 Doug Williams. All rights reserved.
//
//

import Foundation

@IBDesignable

class C29RoundedView: UIView {
    enum RoundingPosition:Int {
        case Top = 0
        case Bottom = 1
    }
    var solidLayer:CALayer = CALayer()
    var cornerMaskLayer:CAShapeLayer = CAShapeLayer()
    var shadowMaskLayer:CAShapeLayer = CAShapeLayer()
    @IBInspectable var roundLower:Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    @IBInspectable var cornerRadius:CGFloat = 8.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    @IBInspectable var includeShadow:Bool = true {
        didSet {
            updateShadow()
        }
    }
    private func updateShadow(){
        if includeShadow {
            self.layer.shadowColor = UIColor.blackColor().CGColor
            self.layer.shadowRadius = 10.0
            self.layer.shadowOpacity = 0.2
        } else {
            self.layer.shadowColor = UIColor.clearColor().CGColor
        }
    }
    private func setupLayers(){
        solidLayer.backgroundColor = self.layer.backgroundColor
        self.layer.backgroundColor = UIColor.clearColor().CGColor
        self.layer.insertSublayer(solidLayer, atIndex: 0)
        updateShadow()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupLayers()
        self.clipsToBounds = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let b = self.bounds
        solidLayer.frame = self.bounds
        cornerMaskLayer.path = UIBezierPath(roundedRect: b,
                                            byRoundingCorners: (roundLower ? [.BottomLeft, .BottomRight] : [.TopLeft, .TopRight]),
                                            cornerRadii: CGSizeMake(cornerRadius, cornerRadius)).CGPath
        solidLayer.mask = cornerMaskLayer
        
        var shadowBounds = b
        if !roundLower {
            shadowBounds.origin.y -= 20.0
        }
        shadowBounds.size.height += 20.0
        shadowMaskLayer.path = UIBezierPath(rect: shadowBounds).CGPath
        self.layer.mask = shadowMaskLayer
        self.layer.shadowPath = cornerMaskLayer.path
    }
}