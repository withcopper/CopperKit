//
//  CopperAlertNumberPadCell.swift
//  Copper
//
//  Created by Doug Williams on 5/6/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

protocol CopperAlertNumberPadCellDelegate {
    func numberPadWasPressed(key: CopperNumberPadKey)
    func numberPadDeleteWasPressed()
    func numberPadDeleteShouldBeEnabled() -> Bool
}

enum CopperNumberPadKey: Int {
    case Zero = 0
    case One = 1
    case Two = 2
    case Three = 3
    case Four = 4
    case Five = 5
    case Six = 6
    case Seven = 7
    case Eight = 8
    case Nine = 9
}

class CopperAlertNumberPadCell: CopperAlertTableViewCell {
    
    // Number Pad components
    @IBOutlet weak var numberPadView: UIView!
    @IBOutlet weak var numberPad1: CopperAlertNumberPadButton!
    @IBOutlet weak var numberPad2: CopperAlertNumberPadButton!
    @IBOutlet weak var numberPad3: CopperAlertNumberPadButton!
    @IBOutlet weak var numberPad4: CopperAlertNumberPadButton!
    @IBOutlet weak var numberPad5: CopperAlertNumberPadButton!
    @IBOutlet weak var numberPad6: CopperAlertNumberPadButton!
    @IBOutlet weak var numberPad7: CopperAlertNumberPadButton!
    @IBOutlet weak var numberPad8: CopperAlertNumberPadButton!
    @IBOutlet weak var numberPad9: CopperAlertNumberPadButton!
    @IBOutlet weak var numberPad0: CopperAlertNumberPadButton!
    @IBOutlet weak var numberPadDelete: CopperAlertNumberPadButton!
    @IBOutlet var numberPadHeightConstraint: NSLayoutConstraint!

    var numberPadDelegate: CopperAlertNumberPadCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // _setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // _setup()
    }
    
    func setup() {
        self.numberPadView.backgroundColor = UIColor.clearColor()
        self.contentView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        self.backgroundColor = UIColor.clearColor()
        // Style the number pad
        numberPad1.setup()
        numberPad2.setup()
        numberPad3.setup()
        numberPad4.setup()
        numberPad5.setup()
        numberPad6.setup()
        numberPad7.setup()
        numberPad8.setup()
        numberPad9.setup()
        numberPad0.setup()
        numberPadDelete.setup()
        // give our selves the press and hold backspace you'd expect
        numberPadDelete.addTarget(self, action: #selector(CopperAlertNumberPadCell.numberPadDeleteButtonPressed(_:)), timeInterval: 0.15)
        numberPadUpdateDeleteButtonStatus()
    }
    
    func numberPadUpdateDeleteButtonStatus() {
        numberPadDelete.enabled = numberPadDelegate?.numberPadDeleteShouldBeEnabled() ?? false
    }
    
    @IBAction func numberPadButtonPressed(sender: AnyObject) {
        let button = sender as! CopperAlertNumberPadButton
        if let text = button.titleLabel?.text,
            let val = Int(text),
            key = CopperNumberPadKey(rawValue: val) {
            numberPadDelegate?.numberPadWasPressed(key)
        }
    }
    
    @IBAction func numberPadDeleteButtonPressed(sender: AnyObject) {
        numberPadDelegate?.numberPadDeleteWasPressed()
    }
    
}

class CopperAlertNumberPadButton: C29TouchAndHoldButton {
    
    func setup() {
        self.layoutIfNeeded()
        self.backgroundColor = UIColor.clearColor()
        self.titleLabel?.font = C29Text.fontForTrait(.NumberPad)
        self.setTitleColor(UIColor.copper_black92(), forState: .Normal)
        self.setTitleColor(UIColor.copper_black40(), forState: .Disabled)
        self.tintColor = UIColor.copper_black92()
    }
    
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                self.titleLabel?.font = C29Text.fontForTrait(.NumberPadPressed)
                self.backgroundColor = UIColor.copper_black20()
            }
            else {
                self.titleLabel?.font = C29Text.fontForTrait(.NumberPad)
                self.backgroundColor = UIColor.clearColor()
            }
        }
    }
}