//
//  CopperAlertTableViewCell.swift
//  Copper
//
//  Created by Doug Williams on 4/25/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

protocol CopperAlertTableViewCellDelegate: class {
    func actionWasPressed(alertAction: C29AlertAction)
}

class CopperAlertTableViewCell: UITableViewCell {
    
//    var indexPath: NSIndexPath?
    var alert: C29Alert?
    var delegate: CopperAlertTableViewCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    func _setup() {    
        self.contentView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.layoutIfNeeded()
        self.layoutSubviews()
    }
    
    func setupForAlert(alert: C29Alert) {
        self.alert = alert
    }
}

class CopperAlertHeaderImageCell: CopperAlertTableViewCell {
    @IBOutlet var headerImageOutlineView: UIView!
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var headerOutlineViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var headerImageViewWidthConstraint: NSLayoutConstraint!
    
    let HeaderOutlineViewWidthConstant: CGFloat = 96.0 // 72.0
    let HeaderImageViewWidthConstant: CGFloat = 88.0 // 66.0
    
    override func setupForAlert(alert: C29Alert) {
        super.setupForAlert(alert)
        self.headerOutlineViewWidthConstraint.constant = HeaderOutlineViewWidthConstant
        self.headerImageOutlineView.layer.cornerRadius = (HeaderOutlineViewWidthConstant / 2)
        self.headerImageViewWidthConstraint.constant = HeaderImageViewWidthConstant
        self.headerImageView.layer.cornerRadius = (HeaderImageViewWidthConstant / 2)
        headerImageOutlineView.layer.shadowColor = UIColor.copper_ModalCardImageShadowColor().CGColor
        headerImageOutlineView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        headerImageOutlineView.layer.shadowOpacity = 0.7
        headerImageOutlineView.layer.shadowRadius = 1.5
        if let headerImage = alert.headerImage {
            self.headerImageView.image = headerImage
        }
    }
}
