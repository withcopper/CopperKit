//
//  CopperAlertTwoActionButtonCell
//  Copper
//
//  Created by Doug Williams on 4/25/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

class CopperAlertTwoActionButtonCell: CopperAlertTableViewCell {
    
    @IBOutlet var buttonLeft: UIButton!
    @IBOutlet var buttonRight: UIButton!
    var actionLeft: C29AlertAction?
    var actionRight: C29AlertAction?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.actionLeft = nil
        self.actionRight = nil
        buttonLeft.hidden = true
        buttonRight.hidden = true
        buttonLeft.alpha = 0.0
        buttonRight.alpha = 0.0
        UIView.setAnimationsEnabled(false)
        buttonLeft.setTitle("", forState: .Normal)
        buttonRight.setTitle("", forState: .Normal)
        UIView.setAnimationsEnabled(true)
    }
    
    func setupForAlertAction(action: C29AlertAction) {
        var button: UIButton!
        if actionLeft == nil {
            self.actionLeft = action
            button = buttonLeft
        } else {
            self.actionRight = action
            button = buttonRight
        }
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        action.delegate = self
        CopperAlertActionButtonCell.setupButtonForAction(action, button: button)
        respondToActionEnabled(action, animated: false)
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        let action: C29AlertAction!
        if sender == buttonLeft {
            action = actionLeft
        } else {
            action = actionRight
        }
        if !(action?.repeatable ?? true) {
            sender.enabled = false
        }
        if let action = action {
            self.delegate?.actionWasPressed(action)
        }
    }
    
    func respondToActionEnabled(action: C29AlertAction, animated: Bool = true) {
        var button: UIButton?
        if let actionLeft = actionLeft where actionLeft == action {
            button = buttonLeft
        } else if let actionRight = actionRight where actionRight == action {
            button = buttonRight
        }
        guard let b = button else { return }
        if action.enabled {
            b.hidden = false
        }
        CopperAlertActionButtonCell.respondToActionEnabled(action, button: b, animated: animated)
    }
    
}

extension CopperAlertTwoActionButtonCell: C29AlertActionDelegate {
    func actionEnabledDidChange(action: C29AlertAction) {
        self.respondToActionEnabled(action, animated: true)
    }
}

