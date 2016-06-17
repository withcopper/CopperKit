//
//  CopperAlertMessageCell.swift
//  Copper
//
//  Created by Doug Williams on 5/7/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

class CopperAlertMessageCell: CopperAlertTableViewCell {
    @IBOutlet var messageLabel: UILabel!
    
    static let DefaultTextColor = UIColor.copper_ModalCardSubTextColor()
    
    override func prepareForReuse() {
        messageTextColor = CopperAlertMessageCell.DefaultTextColor
    }
    
    var messageTextColor = CopperAlertMessageCell.DefaultTextColor {
        didSet {
            setMessage()
        }
    }
    
    override func setupForAlert(alert: C29Alert) {
        super.setupForAlert(alert)
        messageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        messageLabel.numberOfLines = 0 // infinite
        setMessage()
    }
    
    func setMessage() {
        if let message = alert?.message {
            self.messageLabel.attributedText = C29Text.body(message.localized, color: messageTextColor)
        } else {
            self.messageLabel.text = ""
        }
    }
    
    func boldString(subString: String! = nil) {
        if let subString = subString {
            messageLabel.boldSubstring(subString)
        } else if let message = alert?.message {
            messageLabel.boldSubstring(message)
        }
    }
}