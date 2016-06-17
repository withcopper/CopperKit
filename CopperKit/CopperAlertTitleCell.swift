//
//  CopperAlertMessageCell.swift
//  Copper
//
//  Created by Doug Williams on 5/7/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

class CopperAlertTitleCell: CopperAlertTableViewCell {
    @IBOutlet var titleLabel: UILabel!
    
    static let DefaultTitleColor = UIColor.copper_ModalCardTitleColor()
    
    var titleTextColor = CopperAlertTitleCell.DefaultTitleColor {
        didSet {
            setTitle()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleTextColor = CopperAlertTitleCell.DefaultTitleColor
    }
    
    override func setupForAlert(alert: C29Alert) {
        super.setupForAlert(alert)
        self.titleTextColor = CopperAlertTitleCell.DefaultTitleColor
        self.setTitle()
    }
    
    func setTitle() {
        if let title = alert?.title {
            self.titleLabel.attributedText = C29Text.h2(title.localized, color: titleTextColor)
            titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            titleLabel.numberOfLines = 0 // infinite
        } else {
            self.titleLabel.text = ""
        }
    }
    
    func boldString(subString: String! = nil) {
//        if let subString = subString {
//            titleLabel.boldSubstring(subString)
//        } else if let title = alert?.title {
//            titleLabel.boldSubstring(title)
//        }
    }
}

