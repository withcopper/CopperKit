//
//  String+Copper.swift
//  CopperKit
//
//  Created by Doug Williams on 4/19/16.
//  Copyright © 2016 Doug Williams. All rights reserved.
//

import Foundation

extension String {
    
    // Credit: http://www.raywenderlich.com/86205/nsregularexpression-swift-tutorial
    public func clean() -> String {
        let leadingAndTrailingWhitespacePattern = "(?:^\\s+)|(?:\\s+$)"
        
        do {
            let regex = try NSRegularExpression(pattern: leadingAndTrailingWhitespacePattern, options: .CaseInsensitive)
            let range = NSMakeRange(0, self.characters.count)
            let trimmedString = regex.stringByReplacingMatchesInString(self, options: .ReportProgress, range:range, withTemplate:"$1")
            
            return trimmedString
        } catch _ {
            return self
        }
    }
    
    public var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
    public func localizedWithComment(comment: String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment)
    }
    
    // Substring helpers, credit: http://stackoverflow.com/a/24144365/4389523
    // "abcde"[0] === "a"
    // "abcde"[0...2] === "abc"
    
    public subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    public subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
}