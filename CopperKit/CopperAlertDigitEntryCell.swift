//
//  CopperAlertDigitEntryCell.swift
//  Copper
//
//  Created by Doug Williams on 5/6/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation
import QuartzCore

class CopperAlertDigitEntryCell: CopperAlertTableViewCell {
    
    // Digit entry view components
    @IBOutlet weak var digitEntryView: UIView!
    @IBOutlet weak var digit0: CopperKitDigitControl!
    @IBOutlet weak var digit1: CopperKitDigitControl!
    @IBOutlet weak var digit2: CopperKitDigitControl!
    @IBOutlet weak var digit3: CopperKitDigitControl!
    @IBOutlet weak var digit4: CopperKitDigitControl!
    @IBOutlet weak var digit5: CopperKitDigitControl!
    @IBOutlet weak var digitSeparator: CopperKitDigitControl!
    
    var digitControls = [CopperKitDigitControl]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        // Cell setup
        self.contentView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        self.backgroundColor = UIColor.clearColor()

        // Style the entry view background
        self.digitEntryView.backgroundColor = UIColor.clearColor()
        // Style the digits controls
        self.digit0.setup()
        self.digit1.setup()
        self.digit2.setup()
        self.digit3.setup()
        self.digit4.setup()
        self.digit5.setup()
        self.digitControls = [digit0, digit1, digit2, digit3, digit4, digit5]
        
        // Style the digit separator
        self.digitSeparator.borderWidth = 0.0
        digitSeparator.setup()
        digitSeparator.set("-")
    }
    
    func setDigitsEntry(digits: String) {
        let len = digits.characters.count
        for (index, digitControl) in digitControls.enumerate() {
            if index >= len {
                digitControl.reset()
            }
            if index < len {
                digitControl.setActive()
                digitControl.set(digits[index])
            }
        }
    }
    
    func setSuccess() {
        C29Utils.delay(0.05) {
            self.digit0.set("✨")
            C29Utils.delay(0.06) {
                self.digit1.set("🎉")
                C29Utils.delay(0.07) {
                    self.digit2.set("🎈")
                    C29Utils.delay(0.08) {
                        self.digit3.set("🙌")
                        C29Utils.delay(0.09) {
                            self.digit4.set("🌮")
                            C29Utils.delay(0.1) {
                                self.digit5.set("🙃")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setIncorrect() {
        for control in self.digitControls {
            control.setIncorrect()
        }
    }
}

class CopperKitDigitControl: CopperKitEntryControlView {
    
    override func setup() {
        super.setup()
        self.layer.cornerRadius = 6.0
        self.bottomBorder?.hidden = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = UIColor.copper_black40().CGColor
    }
    
    override func set(string: String) {
        let text: String = string[0] // limit to the first char
        self.label?.attributedText = C29Text.h3(text, color: UIColor.copper_black92())
    }
    
    override func reset() {
        super.reset()
        self.setInactive()
    }
    
    func setIncorrect() {
        self.label?.text = "❌"
    }
    
    func setInactive() {
        self.layer.borderColor = UIColor.copper_black40().CGColor
    }
    
    func setActive() {
        self.layer.borderColor = UIColor.copper_black92().CGColor
    }
    
    func setSuccess() {
        self.label?.textColor = UIColor.copper_RegistrationViewSuccessColor()
    }
}

