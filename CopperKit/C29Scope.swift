//
//  C29Scope
//  Copper
//  This is our work-horse class, holding the logic for all operations dealing with CopperRecords
//  and talking back to the network about them.
//
//  Created by Doug Williams on 12/18/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

@objc public enum C29Scope: Int {
    // We must use Ints because these are included in @objc protocols which don't support String backing stores
    // New and unset
    case Null = -1 // unset in API terms
    
    // Order and these numbers matter in two ways
    // First: they signify common groupings (see isMulti... and isDynamicRecord() below)
    // Second: they represent the preferred order of display on the Identity Sheet and Request Sheet
    
    // Multi entries -- records that can have 0-N of the same entries
    // enums can't have stored properties so we leave them here in comments for future reference
    // let MultiRawValueMin = 1000
    // let MultiRawValueMax = 1999
    
    case Name = 1000
    case Picture = 1001
    case Phone = 1002
    case Email = 1003
    case Username = 1004
    case Address = 1005
    case Birthday = 1006
    case Signature = 1007
    
    // Set entries
    case ContactsFavorites = 3001
    
    private static let scopesWithKeys: [C29Scope: String] =
        [C29Scope.Address: "address",
        C29Scope.ContactsFavorites: "contacts",
        C29Scope.Email: "email",
        C29Scope.Name: "name",
        C29Scope.Phone: "phone",
        C29Scope.Picture: "picture",
        C29Scope.Username: "username",
        C29Scope.Birthday: "birthday",
        C29Scope.Signature: "signature"]
    
    public static let All = [C29Scope] (scopesWithKeys.keys)
    public static let DefaultScopes = [C29Scope.Name, C29Scope.Picture, C29Scope.Phone]
    
    public static func fromString(scope: String) -> C29Scope? {
        let keys = scopesWithKeys.filter { $1 == scope }.map { $0.0 }
        // note: returns an array
        if keys.count > 0 {
            return keys.first
        }
        return C29Scope?()
    }
    
    public var value: String? {
        return C29Scope.scopesWithKeys[self]
    }
    
    public var displayName : String {
        switch self {
        case .Address:
            return "Street Address".localized
        case .ContactsFavorites:
            return "Favorite People 👪".localized
        case .Email:
            return "Email Address".localized
        case .Name:
            return "Name".localized
        case .Phone:
            return "Phone Number".localized
        case .Picture:
            return "Picture".localized
        case .Username:
            return "Username".localized
        case .Birthday:
            return "Birthday".localized
        case .Signature:
            return "Signature".localized
        case .Null:
            return "null".localized
        }
    }
    
    public func sectionTitle(numberOfRecords: Int = 0) -> String {
        switch self {
        case .Address:
            if numberOfRecords < 2 {
                return "Shipping Address".localized.uppercaseString
            } else {
                return "Addresses".localized.uppercaseString
            }
        case .ContactsFavorites:
            return "Contacts".localized.uppercaseString
        case .Email:
            if numberOfRecords < 2 {
                return "Email".localized.uppercaseString
            } else {
                return "Emails".localized.uppercaseString
            }
        case .Name, .Picture:
            return "Profile".localized.uppercaseString
        case .Phone:
            if numberOfRecords < 2 {
                return "Number".localized.uppercaseString
            } else {
                return "Numbers".localized.uppercaseString
            }
        case .Username:
            return "Username".localized
        default:
            return self.displayName.uppercaseString
        }
    }
    
    public var addRecordString: String {
        switch self {
        case .Address:
            return "add new shipping address".localized
        case .Email:
            return "add new email".localized
        case .Phone:
            return "add new phone".localized
        case .Username:
            return "add your preferred username".localized
        case .Birthday:
            return "add your birthday".localized
        case .Signature:
            return "add your signature 👆🏾".localized
        default:
            return "We don't use addEntry for this scope 🦄"
        }
    }

    public func createRecord() -> CopperRecordObject? {
        switch self {
        case .Address:
            return CopperAddressRecord()
        case .ContactsFavorites:
            return CopperContactsRecord()
        case .Email:
            return CopperEmailRecord()
        case .Name:
            return CopperNameRecord()
        case .Phone:
            return CopperPhoneRecord()
        case .Picture:
            return CopperPictureRecord()
        case .Username:
            return CopperUsernameRecord()
        case .Birthday:
            return CopperDateRecord()
        case .Signature:
            return CopperSignatureRecord()
        default:
            return CopperRecordObject?()
        }
    }
    
    var dataKeys: [ScopeDataKeys] {
        switch self {
        case .Address:
            return [.AddressStreetOne, .AddressStreetTwo, .AddressCity, .AddressState, .AddressZip, .AddressCountry]
        case .ContactsFavorites:
            return [.ContactsContacts]
        case .Email:
            return [.EmailAddress]
        case .Name:
            return [.NameFirstName, .NameLastName]
        case .Phone:
            return [.PhoneNumber]
        case .Picture:
            return [.PictureImage, .PictureURL]
        case .Username:
            return [.Username]
        case .Birthday:
            return [.Date]
        case .Signature:
            return [.SignatureImage, .SignatureURL]
        case .Null:
            return []
            
        }
    }
    
    public static func getCommaDelinatedString(fromScopes scopes: [C29Scope]?) -> String {
        guard let scopes = scopes  else { return "" }
        var scopesStrings = [String]()
        for scopeString in scopes {
            scopesStrings.append(scopeString.value!)
        }
        return scopesStrings.joinWithSeparator(",")
    }
    
    
    // This is only used for SingleLineEditCell.swift, to set the perferredKeyboard for entry
    // this could potentially be much more robust for all types but for now we limit it to CopperMultiRecords.
    // For example, the AddressEditCell programmatically sets it's own, hard coded, since there is only (currently) one address type
    public var preferredKeyboard: UIKeyboardType? {
        switch self {
        case .Email:
            return .EmailAddress
        case .Phone:
            return .PhonePad
        default:
            return UIKeyboardType?()
        }
    }

}

enum ScopeDataKeys: String {
    // .Address
    case AddressStreetOne = "street_one"
    case AddressStreetTwo = "street_two"
    case AddressCity = "city"
    case AddressState = "state"
    case AddressZip = "zip"
    case AddressCountry = "country"
    // .Email
    case EmailAddress = "email"
    // .Contacts favorites
    case ContactsContacts = "contacts"
    // .Name
    case NameFirstName = "first_name"
    case NameLastName = "last_name"
    // .Phone
    case PhoneNumber = "phone_number"
    // .Picture
    case PictureImage = "picture"
    case PictureURL = "url"
    // .Username
    case Username = "username"
    // .Birthdate
    case Date = "date"
    // .Signature
    case SignatureImage = "image"
    case SignatureURL = "imageUrl"
}