//
//  CopperPhoneNumberEntryCell.swift
//  Copper
//
//  Created by Doug Williams on 5/6/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

class CopperAlertPhoneNumberEntryCell: CopperAlertTableViewCell {

    @IBOutlet weak var phoneEntryView: UIView!
    @IBOutlet weak var countryCodeControl: CopperKitCountryCodeControl!
    @IBOutlet weak var phoneNumberControl: CopperKitPhoneNumberControl!
    var countryPicker: CountryPicker!

    var alertCellDelegate: C29AuthenticationAlertControllerCellDelegate?
    
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
        // Style the Entry UI
        self.phoneEntryView.backgroundColor = UIColor.clearColor()
        countryCodeControl.setup()
        countryCodeControl.delegate = self
        configureCountryPicker()
        phoneNumberControl.setup()
    }
    
    func setPhoneNumber(phoneRecord: CopperPhoneRecord) {
        guard let phoneNumber = phoneRecord.number else {
            phoneNumberControl.reset()
            return
        }
        if phoneNumber.characters.count <= 0 {
            phoneNumberControl.reset()
        } else {
            phoneNumberControl.set(phoneRecord.numberDisplayString)
        }
    }
    
    func setCountryCodeToPrefix(prefix: String) {
        self.countryCodeControl.set(prefix)
    }
    
    private func configureCountryPicker() {
        self.countryPicker = CountryPicker()
        countryPicker.delegate = self
        countryCodeControl.hiddenTextField?.inputView = countryPicker!
    }
    
}

extension CopperAlertPhoneNumberEntryCell: CopperAlertCountryCodeControlDelegate {
    func countryCodeTextFieldDidBecomeFirstResponder() {
        let countryCode = alertCellDelegate?.phoneRecord.countryCode ?? CopperPhoneRecord.DefaultCountryCode
        self.countryPicker.setSelectedCountryCode(countryCode, animated: false)
        self.alertCellDelegate?.countryCodeDidBecomeFirstResponder()
    }
}

extension CopperAlertPhoneNumberEntryCell: CountryPickerDelegate {
    func countryPicker(picker: CountryPicker, didSelectCountryWithName name: String, code: String) {
        self.alertCellDelegate?.didUpdateCountryCode(code)
    }
}

protocol CopperAlertCountryCodeControlDelegate {
    func countryCodeTextFieldDidBecomeFirstResponder()
}

class CopperKitCountryCodeControl: CopperKitEntryControlView {
    
    var hiddenTextField: CountryCodeTextField?
    var delegate: CopperAlertCountryCodeControlDelegate? {
        didSet {
            hiddenTextField?.countryCodeDelegate = delegate
        }
    }
    
    override func setup() {
        super.setup()
        hiddenTextField = CountryCodeTextField(frame: self.bounds)
        self.addSubview(hiddenTextField!)
        configureHiddenTextField()
    }
    
    override func reset() {
        var prefix = "+1" // a reasonable default
        let countryCode = CopperPhoneRecord.DefaultCountryCode
        if let p = CopperPhoneRecord.getPrefixForCountryCode(countryCode) {
            prefix = "+\(p)"
        }
        self.label?.attributedText = C29Text.h2(prefix, color: UIColor.copper_black92())
    }
    
    func configureHiddenTextField() {
        // 1. basic configuration we want for all textFields
        hiddenTextField?.backgroundColor = UIColor.clearColor()
        hiddenTextField?.tintColor = UIColor.clearColor()
        hiddenTextField?.textColor = UIColor.clearColor()
    }
    
    override func resignFirstResponder() -> Bool {
        hiddenTextField?.resignFirstResponder()
        return true
    }
    
    class CountryCodeTextField: UITextField {
        var countryCodeDelegate: CopperAlertCountryCodeControlDelegate?
        override func becomeFirstResponder() -> Bool {
            super.becomeFirstResponder()
            countryCodeDelegate?.countryCodeTextFieldDidBecomeFirstResponder()
            return true
        }
    }
}

class CopperKitPhoneNumberControl: CopperKitEntryControlView {
    
    var placeholderLabel: UILabel?
    let placeholderText = "Mobile Number"
    
    override func setup() {
        // order matters here to ensure objects are initialized properly
        placeholderLabel = UILabel(frame: self.bounds)
        placeholderLabel?.textAlignment = .Left
        self.addSubview(placeholderLabel!)
        super.setup()
        // plan for the highly unlikely event that we'll have a size issue
        label!.adjustsFontSizeToFitWidth = true
        label!.minimumScaleFactor = 0.5
        label!.textAlignment = .Left
        label!.lineBreakMode = .ByTruncatingHead
        self.layoutIfNeeded()
        reset()
    }
    
    override func reset() {
        self.set("")
        self.placeholderLabel?.attributedText = C29Text.h3(placeholderText, color: UIColor.copper_black40())
        self.placeholderLabel?.sizeToFit()
        UIView.animateWithDuration(C29Utils.animationDuration, animations: {
            self.placeholderLabel?.center.y = self.label!.center.y
        })
    }
    
    override func set(string: String) {
        let text = string
        label?.attributedText = C29Text.h2(text, color: UIColor.copper_black92())
        // update the placeholder text
        self.placeholderLabel!.attributedText = C29Text.label_small(placeholderText.uppercaseString, color: UIColor.copper_black40())
        placeholderLabel?.textColor = UIColor.copper_black40()
        self.placeholderLabel?.sizeToFit()
        UIView.animateWithDuration(C29Utils.animationDuration, animations: {
            self.placeholderLabel?.center.y = self.frame.origin.y + (self.placeholderLabel!.frame.size.height/2)
        })
    }
    
}