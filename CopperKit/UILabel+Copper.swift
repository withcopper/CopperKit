//
//  UILabel+Copper.swift
//  CopperKit
//
//  Created by Doug Williams on 5/28/16.
//  Copyright © 2016 Doug Williams. All rights reserved.
//

import UIKit

extension UILabel {
    
    public func boldRange(range: Range<String.Index>) {
        if let text = self.attributedText {
            let attr = NSMutableAttributedString(attributedString: text)
            let start = text.string.startIndex.distanceTo(range.startIndex)
            let length = range.startIndex.distanceTo(range.endIndex)
            attr.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(self.font!.pointSize)], range: NSMakeRange(start, length))
            self.attributedText = attr
        }
    }
    
    public func boldSubstring(substr: String) {
        let range = self.text?.rangeOfString(substr)
        if let r = range {
            boldRange(r)
        }
    }
    
}