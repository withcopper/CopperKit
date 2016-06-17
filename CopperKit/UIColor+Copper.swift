//
//  UIColor+Copper.swift
//  Copper
//
//  Created by Benjamin Sandofsky on 8/5/15.
//  Copyright (c) 2015 Doug Williams. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    // MARK: - Identity Sheet
    
    public class func copper_IdentitySheetBackgroundColor() -> UIColor {
        return self.copper_primaryCopper()
    }
    
    public class func copper_IdentitySheetNameColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_IdentitySheetScopeColor() -> UIColor {
        return self.copper_black60()
    }
    
    public class func copper_IdentitySheetValueColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_IdentitySheetTintColor() -> UIColor {
        return self.copper_primaryVerdigris()
    }
    
    public class func copper_IdentitySheetEditTextColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_IdentitySheetTextInputPlaceholderTextColor() -> UIColor {
        return self.copper_white32()
    }
    
    public class func copper_IdentitySheetBorderColor() -> UIColor {
        return self.copper_black20()
    }
    
    public class func copper_IdentitySheetEditAvatarIconColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_IdentitySheetSwitchColor() -> UIColor {
        return self.copper_primaryVerdigris()
    }
    
    public class func copper_IdentitySheetToggleValueLabelEnabledColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_IdentitySheetToggleValueLabelDisabledColor() -> UIColor {
        return self.copper_white52()
    }
    
    public class func copper_IdentitySheetSwitchBackgroundColor() -> UIColor {
        return UIColor.hexStringToUIColor("#DE7448")
    }
    
    public class func copper_IdentitySheetAvatarShadowColor() -> UIColor {
        return self.copper_black20()
    }
    
    public class func copper_IdentitySheetSettingsButtonColor() -> UIColor {
        return UIColor.copper_white()
    }
    
    public class func copper_DefaultAvatarIconColor() -> UIColor {
        return self.copper_black20()
    }
    
    public class func copper_IdentitySheetAvatarShadowViewBackgroundColor() -> UIColor {
        return self.copper_white()
    }
    
    // MARK: - Cards
    
    public class func copper_CardHeaderArrowColor() -> UIColor {
        return self.copper_black40()
    }
    
    public class func copper_CardHeaderTitleColor() -> UIColor {
        return self.copper_black60()
    }
    
    public class func copper_CardHeaderSubtitleColor() -> UIColor {
        return self.copper_black()
    }
    
    // MARK: - Application Card Specific Values
    
    public class func copper_ClientBackgroundColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_ClientNameLabelColor() -> UIColor {
        return self.copper_black()
    }
    
    public class func copper_ClientSecondaryLabelColor() -> UIColor {
        return self.copper_black40()
    }
    
    public class func copper_ApplicationCardIconBorderColor() -> UIColor {
        return self.copper_black20()
    }
    
    // MARK: - Request Action Sheet
    
    public class func copper_RequestSheetBackgroundColor() -> UIColor {
        return self.hexStringToUIColor("495252")
        // this color gives us #394040 when the overlay (black @ 0.2 alpha) is applied
    }
    
    public class func copper_RequestSheetBackgroundColorOverlay() -> UIColor {
        return self.copper_black().colorWithAlphaComponent(0.2)
    }
    
    public class func copper_RequestSheetTableViewBackgroundColor() -> UIColor {
        return self.hexStringToUIColor("F9F9F9").colorWithAlphaComponent(0.96)
    }
    
    public class func copper_RequestSheetBorderColor() -> UIColor {
        return self.copper_black20()
    }
    
    public class func copper_CopperRequestHeaderCloseButtonTintColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_CopperRequestHeaderApplicationNameColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_RequestSheetTableViewHeaderBackgroundColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_RequestViewControllerQuickSelectDefaultColor() -> UIColor {
        return self.copper_black40()
    }
    
    public class func copper_RequestViewControllerQuickSelectSelectedColor() -> UIColor {
        return self.copper_primaryCopper()
    }
    
    public class func copper_RequestSheetHeaderTextColor() -> UIColor {
        return self.copper_black60()
    }
    
    public class func copper_RequestSheetValueColor() -> UIColor {
        return self.copper_black()
    }
    
    public class func copper_RequestSheetTextInputPlaceholderTextColor() -> UIColor {
        return self.copper_primaryCopper().colorWithAlphaComponent(0.5)
    }
    
    // MARK: - Open Footer View
    
    public class func copper_RequestSheetOpenLabelColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_RequestSheetOpenLabelDisabledColor() -> UIColor {
        return self.copper_primaryCopper()
    }
    
    public class func copper_RequestSheetOpenButtonColor() -> UIColor {
        return self.copper_primaryCopper()
    }
    
    public class func copper_RequestSheetOpenButtonDismissedColor() -> UIColor {
        return self.copper_secondaryRed()
    }
    
    public class func copper_RequestSheetOpenButtonSendingColor() -> UIColor {
        return self.copper_white72()
    }
    
    public class func copper_RequestSheetOpenButtonSuccessColor() -> UIColor {
        return self.copper_primaryGreen()
    }
    
    public class func copper_RequestSheetOpenButtonSendingBorderColor() -> UIColor {
        return self.copper_black20()
    }
    
    public class func copper_RequestViewControllerOpenButtonGradientTop() -> UIColor {
        return self.hexStringToUIColor("FFFFFF").colorWithAlphaComponent(0.0)
    }
    
    public class func copper_RequestViewControllerOpenButtonGradientBottom() -> UIColor {
        return self.hexStringToUIColor("FFFFFF").colorWithAlphaComponent(0.8)
    }
    
    // MARK: - Settings
    
    public class func copper_SettingsBackgroundColor() -> UIColor {
        return self.copper_midnightGrey()
    }
    
    public class func copper_SettingsSectionHeaderColor() -> UIColor {
        return self.copper_white().colorWithAlphaComponent(0.52)
    }
    
    public class func copper_SettingsCellTitleTextColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_SettingsCellSecondaryTextColor() -> UIColor {
        return self.copper_white().colorWithAlphaComponent(0.52)
    }
    
    public class func copper_SettingsSeparatorViewColor() -> UIColor {
        return self.copper_white().colorWithAlphaComponent(0.12)
    }
    
    public class func copper_SettingsTableViewFooterVersionColor() -> UIColor {
        return self.copper_white().colorWithAlphaComponent(0.32)
    }
    
    public class func copper_SettingsTableViewNavBarTextColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_SettngsTableViewNavigationControllerBackColor() -> UIColor {
        return self.copper_white().colorWithAlphaComponent(0.52)
    }
    
    // MARK: - Contacts Picker
    
    public class func copper_ContactsPickerTextColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_ContactsPickerTintColor() -> UIColor {
        return self.copper_primaryGreen()
    }
    
    public class func copper_ContactsPickerViewBackgroundColor() -> UIColor {
        return self.copper_white().colorWithAlphaComponent(0.20)
    }
    
    public class func copper_ContactsPickerPlaceholderTextColor() -> UIColor {
        return self.copper_white20()
    }
    
    public class func copper_ContactsPickerNavBarTintColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_ContactsPickerHeaderBackgroundColor() -> UIColor {
        return self.copper_black().colorWithAlphaComponent(0.3)
    }
    
    // MARK: Onboarding
    
    
    public class func copper_OnboardingViewTextColor() -> UIColor {
        return self.whiteColor()
    }
    
    public class func copper_OnboardingViewSubTextColor() -> UIColor {
        return self.copper_white72()
    }
    
    public class func copper_OnboardingViewContinueButtonTextColor() -> UIColor {
        return self.hexStringToUIColor("#222324")
    }
    
    public class func copper_OnboardingViewContinueButtonColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_OnboardingViewLegalButtonTextColor() -> UIColor {
        return self.copper_white52()
    }
    
    public class func copper_OnboardingViewShadowGradientTopColor() -> UIColor {
        return self.copper_black().colorWithAlphaComponent(0.0)
    }
    
    public class func copper_OnboardingViewShadowGradientBottomColor() -> UIColor {
        return self.copper_black().colorWithAlphaComponent(0.32)
    }
    
    // MARK: Registration
    
    public class func copper_RegistrationViewBackgroundColor() -> UIColor {
        return self.copper_midnightGrey()
    }
    
    public class func copper_RegistrationViewPrimaryTextColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_RegistrationViewSecondaryTextColor() -> UIColor {
        return self.copper_white32()
    }
    
    public class func copper_RegistrationViewErrorTextColor() -> UIColor {
        return self.copper_primaryCopper()
    }
    
    public class func copper_RegistrationViewBorderColor() -> UIColor {
        return self.copper_white20()
    }
    
    public class func copper_RegistrationViewSuccessColor() -> UIColor {
        return self.copper_primaryGreen()
    }
    
    public class func copper_RegistrationViewNumberPadHightlightColor() -> UIColor {
        return self.copper_white32()
    }
    
    public class func copper_RegistrationViewSendButtonColor() -> UIColor {
        return self.hexStringToUIColor("#00D49F")
    }
    
    
    // MARK: - Misc
    
    public class func copper_IdentityCellKeyboardToolbarTintColor() -> UIColor {
        // background color for the dark keyboard is #565656
        // See technical note on what we have to do to arrive at our value for this color to deal with the translucent bar https://developer.apple.com/library/ios/qa/qa1808/_index.html
        return UIColor.hexStringToUIColor("A2A2A2").colorWithAlphaComponent(0.2)
    }
    
    public class func copper_RegistrationColor() -> UIColor {
        return self.copper_secondaryBlue()
    }
    
    public class func copper_ActivityIndicatorBackgroundColor() -> UIColor {
        return self.copper_white72()
    }
    
    
    // MARK: AuthControllerView Colors
    
    public class func copper_AuthenticationControllerTitleColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_AuthenticationControllerTextViewColor() -> UIColor {
        return self.copper_white72()
    }
    
    public class func copper_AuthenticationControllerButtonDefaultColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_AuthenticationControllerButtonDisabledColor() -> UIColor {
        return self.copper_AuthenticationControllerButtonDefaultColor().colorWithAlphaComponent(0.30)
    }
    
    // MARK: Document Viewer
    
    public class func copper_DocumentViewControllerPrimaryColor() -> UIColor {
        return self.copper_black92()
    }
    
    public class func copper_DocumentViewControllerNetworkIndicatorColor() -> UIColor {
        return self.copper_primaryCopper()
    }
    
    public class func copper_DocumentViewControllerNavBarColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_DocumentViewControllerNavBarBottomColor() -> UIColor {
        return self.copper_black().colorWithAlphaComponent(0.12)
    }
    
    // MARK: Modal Card View
    
    public class func copper_ModalCardChromeBackgroundColor() -> UIColor {
        return self.copper_black60()
    }
    
    public class func copper_ModalCardBackgroundColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_ModalCardTitleColor() -> UIColor {
        return self.copper_black92()
    }
    
    public class func copper_ModalCardSubTextColor() -> UIColor {
        return self.copper_black60()
    }
    
    public class func copper_ModalCardActionButtonBackgroundColor() -> UIColor {
        return self.copper_black()
    }
    
    public class func copper_ModalCardActionButtonTextColor() -> UIColor {
        return self.copper_white()
    }
    
    public class func copper_ModalCardCloseButtonTextColor() -> UIColor {
        return self.copper_black60()
    }
    
    public class func copper_ModalCardImageShadowColor() -> UIColor {
        return self.copper_black().colorWithAlphaComponent(0.16)
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // MARK: Brand colors below here.
    // See: https://www.dropbox.com/s/lmdim3pmo3mzt9a/copper-colors.sketch?dl=0
    
    // MARK: - Primary
    
    public class func copper_primaryCopper() -> UIColor {
        return UIColor.hexStringToUIColor("D95C27")
    }
    
    public class func copper_primaryGreen() -> UIColor {
        return UIColor.hexStringToUIColor("00D49F")
    }
    
    public class func copper_primaryVerdigris() -> UIColor {
        return UIColor.hexStringToUIColor("14FFC4")
    }
    
    public class func copper_midnightGrey() -> UIColor {
        return UIColor.hexStringToUIColor("#17181A")
    }
    
    // MARK: - Secondary
    
    public class func copper_secondaryBlue() -> UIColor {
        return UIColor.hexStringToUIColor("0A4BFF")
    }
    
    public class func copper_secondaryPurple() -> UIColor {
        return UIColor.hexStringToUIColor("6614F5")
    }
    
    public class func copper_secondaryPink() -> UIColor {
        return UIColor.hexStringToUIColor("FF309F")
    }
    
    public class func copper_secondaryRed() -> UIColor {
        return UIColor.hexStringToUIColor("F52229")
    }
    
    public class func copper_secondaryOrange() -> UIColor {
        return UIColor.hexStringToUIColor("FF620D")
    }
    
    public class func copper_secondaryYellow() -> UIColor {
        return UIColor.hexStringToUIColor("FFD500")
    }
    
    // MARK: - Soft palatte
    
    public class func copper_softGreen() -> UIColor {
        return UIColor.hexStringToUIColor("93F5D4")
    }
    
    public class func copper_softBlue() -> UIColor {
        return UIColor.hexStringToUIColor("A8E8FF")
    }
    
    public class func copper_softPurple() -> UIColor {
        return UIColor.hexStringToUIColor("CCCCFF")
    }
    
    public class func copper_softPink() -> UIColor {
        return UIColor.hexStringToUIColor("FFC7E5")
    }
    
    public class func copper_softOrange() -> UIColor {
        return UIColor.hexStringToUIColor("FFC3B8")
    }
    
    public class func copper_softYellow() -> UIColor {
        return UIColor.hexStringToUIColor("FFE0B8")
    }
    
    // MARK: - Dark Palatte
    
    public class func copper_darkGreen() -> UIColor {
        return UIColor.hexStringToUIColor("00664B")
    }
    
    public class func copper_darkBlue() -> UIColor {
        return UIColor.hexStringToUIColor("1D2C8F")
    }
    
    public class func copper_darkPurple() -> UIColor {
        return UIColor.hexStringToUIColor("65177A")
    }
    
    public class func copper_darkBrown() -> UIColor {
        return UIColor.hexStringToUIColor("662C1D")
    }
    
    // MARK: - Black Palatte
    
    public class func copper_black() -> UIColor {
        return UIColor.hexStringToUIColor("000000")
    }
    
    public class func copper_black92() -> UIColor {
        return UIColor.hexStringToUIColor("000000").colorWithAlphaComponent(0.92)
    }
    
    public class func copper_black60() -> UIColor {
        return UIColor.hexStringToUIColor("000000").colorWithAlphaComponent(0.60)
    }
    
    public class func copper_black40() -> UIColor {
        return UIColor.hexStringToUIColor("000000").colorWithAlphaComponent(0.40)
    }
    
    public class func copper_black20() -> UIColor {
        return UIColor.hexStringToUIColor("000000").colorWithAlphaComponent(0.20)
    }
    
    public class func copper_black08() -> UIColor {
        return UIColor.hexStringToUIColor("000000").colorWithAlphaComponent(0.08)
    }
    
    // MARK: - White palatte
    
    public class func copper_white() -> UIColor {
        return UIColor.hexStringToUIColor("FFFFFF")
    }
    
    public class func copper_white95() -> UIColor {
        return UIColor.hexStringToUIColor("FFFFFF").colorWithAlphaComponent(0.95)
    }
    
    public class func copper_white72() -> UIColor {
        return UIColor.hexStringToUIColor("FFFFFF").colorWithAlphaComponent(0.72)
    }
    
    public class func copper_white52() -> UIColor {
        return UIColor.hexStringToUIColor("FFFFFF").colorWithAlphaComponent(0.52)
    }
    
    public class func copper_white32() -> UIColor {
        return UIColor.hexStringToUIColor("FFFFFF").colorWithAlphaComponent(0.32)
    }
    
    public class func copper_white20() -> UIColor {
        return UIColor.hexStringToUIColor("FFFFFF").colorWithAlphaComponent(0.20)
    }
    
    // MARK: - Helper methods
    
    public class func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    /**
     Hex string of a UIColor instance.
     
     - parameter rgba: Whether the alpha should be included.
     */
    public func hexString(includeAlpha: Bool) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        if (includeAlpha) {
            return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
        } else {
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
    }
}