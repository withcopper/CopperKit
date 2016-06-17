//
//  C29Text.swift
//  Copper
//
//  Created by Doug Williams on 4/19/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import UIKit

public class C29Text {
    
    static let DefaultTextColor = UIColor.blackColor()
    
    // Codifying https://paper.dropbox.com/doc/iOS-Design-Sweep-hsj0j9mwOdRqCIkgkGwHW

    private class func attributedText(text: String, color: UIColor! = nil, size: CGFloat, lineHeight: CGFloat, letterSpacing: CGFloat, weight: CGFloat) -> NSAttributedString {
        let textColor = color == nil ? C29Text.DefaultTextColor : color!
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: [
                NSFontAttributeName: UIFont.systemFontOfSize(size, weight: weight),
                NSForegroundColorAttributeName: textColor,
                NSKernAttributeName: letterSpacing
            ]
        )
        // line height
// TODO untested thus commented out and ignored
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = lineHeight
//        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range:NSMakeRange(0, attributedText.length))
        return attributedText
    }
    
    public enum C29TextFontTrait {
        case H1
        case H2
        case H3
        case Body
        case BodySmall
        case Link
        case LinkSmall
        case Label
        case LabelSmall
        // special cases
        case NumberPad
        case NumberPadPressed
        
        var size: CGFloat {
            switch self {
            case H1:
                return 40.0
            case H2:
                return 28.0
            case H3:
                return 20.0
            case Body:
                return 17.0
            case BodySmall:
                return 12.0
            case Link:
                return 20.0
            case LinkSmall:
                return 15.0
            case Label:
                return 13.0
            case LabelSmall:
                return 10.0
            case NumberPad:
                return 28.0
            case NumberPadPressed:
                return 34.0
            }
        }
        
        var lineHeight: CGFloat {
            switch self {
            case H1:
                return 48.0
            case H2:
                return 36.0
            case H3:
                return 28.0
            case Body:
                return 20.0
            case BodySmall:
                return 18.0
            case Link:
                return 24.0
            case LinkSmall:
                return 18.0
            case Label:
                return 15.0
            case LabelSmall:
                return 12.0
            case .NumberPad:
                return 34.0
            case .NumberPadPressed:
                return 40.0
            }
        }
        
        var letterSpacing: CGFloat {
            switch self {
            case H1, H2, H3, Link, LinkSmall, NumberPad, NumberPadPressed:
                return 0.5
            case Body, BodySmall:
                return 0.0
            case Label, LabelSmall:
                return 0.3
            }
        }
        
        var weight: CGFloat {
            switch self {
            case H1, H2, H3, Body, BodySmall, NumberPad, NumberPadPressed:
                return UIFontWeightRegular
            case Link, LinkSmall, LabelSmall:
                return UIFontWeightMedium
            case Label:
                return UIFontWeightSemibold
            }
        }
    }
    
    // Convenience menthods
    
    public class func fontForTrait(trait: C29TextFontTrait) -> UIFont {
        return UIFont.systemFontOfSize(trait.size, weight: trait.weight)
    }
    
    public class func h1(text: String, color: UIColor! = nil) -> NSAttributedString {
        let trait = C29TextFontTrait.H1
        return C29Text.attributedText(text, color: color, size: trait.size, lineHeight: trait.lineHeight, letterSpacing: trait.letterSpacing, weight: trait.weight)
    }

    public class func h2(text: String, color: UIColor! = nil) -> NSAttributedString {
        let trait = C29TextFontTrait.H2
        return C29Text.attributedText(text, color: color, size: trait.size, lineHeight: trait.lineHeight, letterSpacing: trait.letterSpacing, weight: trait.weight)
    }
    
    public class func h3(text: String, color: UIColor! = nil) -> NSAttributedString {
        let trait = C29TextFontTrait.H3
        return C29Text.attributedText(text, color: color, size: trait.size, lineHeight: trait.lineHeight, letterSpacing: trait.letterSpacing, weight: trait.weight)
    }
    
    public class func body(text: String, color: UIColor! = nil, lineHeight: CGFloat = C29TextFontTrait.Body.lineHeight) -> NSAttributedString {
        let trait = C29TextFontTrait.Body
        return C29Text.attributedText(text, color: color, size: trait.size, lineHeight: trait.lineHeight, letterSpacing: trait.letterSpacing, weight: trait.weight)
    }
    
    public class func body_small(text: String, color: UIColor! = nil) -> NSAttributedString {
        let trait = C29TextFontTrait.BodySmall
        return C29Text.attributedText(text, color: color, size: trait.size, lineHeight: trait.lineHeight, letterSpacing: trait.letterSpacing, weight: trait.weight)
    }
    
    public class func link(text: String, color: UIColor! = nil) -> NSAttributedString {
        let trait = C29TextFontTrait.Link
        return C29Text.attributedText(text, color: color, size: trait.size, lineHeight: trait.lineHeight, letterSpacing: trait.letterSpacing, weight: trait.weight)
    }
    
    public class func link_small(text: String, color: UIColor! = nil) -> NSAttributedString {
        let trait = C29TextFontTrait.LinkSmall
        return C29Text.attributedText(text, color: color, size: trait.size, lineHeight: trait.lineHeight, letterSpacing: trait.letterSpacing, weight: trait.weight)
    }
    
    public class func label(text: String, color: UIColor! = nil) -> NSAttributedString {
        let trait = C29TextFontTrait.Label
        return C29Text.attributedText(text, color: color, size: trait.size, lineHeight: trait.lineHeight, letterSpacing: trait.letterSpacing, weight: trait.weight)
    }
    
    public class func label_small(text: String, color: UIColor! = nil) -> NSAttributedString {
        let trait = C29TextFontTrait.LabelSmall
        return C29Text.attributedText(text, color: color, size: trait.size, lineHeight: trait.lineHeight, letterSpacing: trait.letterSpacing, weight: trait.weight)
    }
}