//
//  C29Bytes
//  Copper
//
//  Created by Doug Williams on 12/1/15.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import Foundation

public class C29Bytes {
    
    enum Key: String {
        case URL = "url"
        case FileId = "file_id"
    }
    
    let fileId: String!
    let url: NSURL!

    init(fileId: String, url: NSURL) {
        self.fileId = fileId
        self.url = url
    }
    
    public class func fromDictionary(dataDict: NSDictionary) -> C29Bytes? {
        if let fileId = dataDict[Key.FileId.rawValue] as? String,
            let url = dataDict[Key.URL.rawValue] as? String {
                guard let _url = NSURL(string: url) else {
                    return nil
                }
                return C29Bytes(fileId: fileId, url: _url)
        }
        return nil
    }
}