//
//  Copper+UIImage
//  Copper
//
//  Created by Doug Williams on 1/19/15.
//  Copyright (c) 2015 Doug Williams. All rights reserved.
//

import UIKit

extension UIImage {
    
    public class func c29_imageFromUrl(url: String, callback: (image: UIImage?)->()) {
        if let u = NSURL(string: url) {
            let request = NSURLRequest(URL: u)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if let imageData = data as NSData? {
                    callback(image: UIImage(data: imageData))
                } else {
                    callback(image: nil)
                }
            }
            return
        }
        callback(image: nil)
    }
    
    public func c29_resizeToWidth(newWidth: CGFloat) -> CGSize {
        let curWidth = self.size.width
        let curHeight = self.size.height
        let ratio = newWidth / curWidth
        let newHeight = curHeight * ratio
        let newSize = CGSizeMake(newWidth, newHeight)
        return newSize
    }

}