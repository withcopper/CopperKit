//
//  CopperAlertButtonCell.swift
//  Copper
//
//  Created by Doug Williams on 4/25/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

class CopperAlertActionButtonCell: CopperAlertTableViewCell {
    
    @IBOutlet var button: UIButton!
    var action: C29AlertAction?
    
    override func prepareForReuse() {
        self.action = nil
        button.hidden = true
    }
    
    func setupForAlertAction(action: C29AlertAction) {
        self.action = action
        action.delegate = self
        self.button.titleLabel?.adjustsFontSizeToFitWidth = true
        CopperAlertActionButtonCell.setupButtonForAction(action, button: button)
    }
    
    class func setupButtonForAction(action: C29AlertAction, button: UIButton) {
        button.backgroundColor = UIColor.clearColor()
        let backgroundColor: UIColor!
        let textColor: UIColor!
        switch action.format {
        case .Inline:
            switch action.style {
            case .Destructive:
                textColor = UIColor.copper_secondaryRed()
            case .Suggestive:
                textColor = UIColor.copper_secondaryBlue()
            case .Green:
                textColor = UIColor.copper_primaryGreen()
            default:
                textColor = UIColor.copper_ModalCardCloseButtonTextColor()
            }
            backgroundColor = UIColor.clearColor()
        case .Default:
            switch action.style {
            case .Destructive:
                backgroundColor = UIColor.copper_secondaryRed()
            case .Suggestive:
                backgroundColor = UIColor.copper_secondaryBlue()
            case .Green:
                backgroundColor = UIColor.copper_primaryGreen()
            default:
                backgroundColor = UIColor.copper_ModalCardActionButtonBackgroundColor()
            }
            textColor = UIColor.copper_ModalCardActionButtonTextColor()
            button.layer.cornerRadius = 5.0
        }
        button.backgroundColor = backgroundColor
        let title: NSAttributedString = C29Text.link(action.title.localized, color: textColor)
        UIView.setAnimationsEnabled(false)
        button.setAttributedTitle(title, forState: .Normal)
        UIView.setAnimationsEnabled(true)
        button.hidden = false
        respondToActionEnabled(action, button: button, animated: false)
    }
    
    class func respondToActionEnabled(action: C29AlertAction, button: UIButton, animated: Bool = false) {
        let duration = animated ? C29Utils.animationDuration : 0.0
        UIView.animateWithDuration(duration,
            animations: {
                button.alpha = action.enabled ? 1.0 : 0.0
            },
            completion: { finished in
                if !action.enabled {
                    button.hidden = true
                }
            }
        )
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        if !(action?.repeatable ?? true) {
            sender.enabled = false
        }
        if let action = action {
            self.delegate?.actionWasPressed(action)
        }
    }
}

extension CopperAlertActionButtonCell: C29AlertActionDelegate {
    func actionEnabledDidChange(action: C29AlertAction) {
        if let a = self.action where a == action {
            CopperAlertActionButtonCell.respondToActionEnabled(action, button: self.button, animated: true)
        }
    }
}
