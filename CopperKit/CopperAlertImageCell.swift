//
//  CopperAlertImageCell.swift
//  Copper
//
//  Created by Doug Williams on 5/7/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

class CopperAlertImageCell: CopperAlertTableViewCell {
    @IBOutlet var _imageView: UIImageView!
    @IBOutlet var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewHeightConstraint: NSLayoutConstraint!
    
    static let DefaultTintColor:UIColor? = nil
    
    override func prepareForReuse() {
        _imageView.tintColor = CopperAlertImageCell.DefaultTintColor
    }
    
    var imageTintColor = CopperAlertImageCell.DefaultTintColor {
        didSet {
            if let image = alert?.image {
                setImage(image, tintColor: tintColor)
            }
        }
    }
    
    override func setupForAlert(alert: C29Alert) {
        super.setupForAlert(alert)
        if let image = alert.image {
            setImage(image)
        }
    }
    
    func setImage(image: UIImage, tintColor: UIColor! = nil) {
        // we automatically resize if necessary
        var size = image.size
        if image.size.width > self.contentView.frame.width {
            size = image.c29_resizeToWidth(self.contentView.frame.width)
        }
        self._imageView.image = image
        self._imageView.tintColor = imageTintColor
        self.imageViewHeightConstraint.constant = size.height
        self.imageViewWidthConstraint.constant = size.width
    }
}