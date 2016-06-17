//
//  Array+String
//  Copper
//
//  Created by Doug Williams on 12/18/15.
//  Copyright (c) 2015 Doug Williams. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {
    
    // removes an object from the array by value, assumes only one entry of this type
    public mutating func removeObject(object : Generator.Element) -> Int? {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
            return index
        }
        return Int?()
    }
    
    public var empty: Bool {
        return self.count == 0
    }
    
}