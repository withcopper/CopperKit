//
//  CopperAddressRecord.swift
//  Cobject Representation of a phone number
//
//  Created by Doug Williams on 6/4/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

public class CopperAddressRecord: CopperRecordObject, CopperAddress {
    
    public override var isBlank:Bool {
        return streetOne == nil && streetTwo == nil && city == nil && state == nil && zip == nil && country == nil
    }
    
    public var streetOne: String? {
        get {
            if let code = self.data[ScopeDataKeys.AddressStreetOne.rawValue] as? String {
                return code
            }
            return String?()
        }
        set {
            if let new = newValue?.clean() where !new.isEmpty {
                self.data[ScopeDataKeys.AddressStreetOne.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.AddressStreetOne.rawValue)
            }
            self.uploaded = false
        }
    }
    
    public var streetTwo: String? {
        get {
            if let code = self.data[ScopeDataKeys.AddressStreetTwo.rawValue] as? String {
                return code
            }
            return String?()
        }
        set {
            if let new = newValue?.clean() where !new.isEmpty {
                self.data[ScopeDataKeys.AddressStreetTwo.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.AddressStreetTwo.rawValue)
            }
            self.uploaded = false
        }
    }
    
    public var city: String? {
        get {
            if let c = self.data[ScopeDataKeys.AddressCity.rawValue] as? String {
                return c
            }
            return String?()
        }
        set {
            if let new = newValue?.clean() where !new.isEmpty {
                self.data[ScopeDataKeys.AddressCity.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.AddressCity.rawValue)
            }
            self.uploaded = false
        }
    }
    
    public var state: String? {
        get {
            if let s = self.data[ScopeDataKeys.AddressState.rawValue] as? String {
                return s
            }
            return String?()
        }
        set {
            if let new = newValue?.clean() where !new.isEmpty {
                self.data[ScopeDataKeys.AddressState.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.AddressState.rawValue)
            }
            self.uploaded = false
        }
    }
    
    public var zip: String? {
        get {
            if let code = self.data[ScopeDataKeys.AddressZip.rawValue] as? String {
                return code
            }
            return String?()
        }
        set {
            if let new = newValue?.clean() where !new.isEmpty {
                self.data[ScopeDataKeys.AddressZip.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.AddressZip.rawValue)
            }
            self.uploaded = false
        }
    }
    
    public var country: String? {
        get {
            if let c = self.data[ScopeDataKeys.AddressCountry.rawValue] as? String {
                return c
            }
            return String?()
        }
        set {
            if let new = newValue?.clean() where !new.isEmpty {
                self.data[ScopeDataKeys.AddressCountry.rawValue] = new
            } else {
                self.data.removeValueForKey(ScopeDataKeys.AddressCountry.rawValue)
            }
            self.uploaded = false
        }
    }
    
    public convenience init(streetOne: String! = nil, streetTwo: String! = nil, city: String! = nil, state: String! = nil, zip: String! = nil, country: String! = nil, id: String = "current", verified: Bool = false) {
        self.init(scope: C29Scope.Address, data: nil, id: id, verified: verified)
        self.streetOne = streetOne
        self.streetTwo = streetTwo
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country

    }
    
    // returns true if the cobject conforms to all requirements of its Type
    public override var valid: Bool {
        get {
            // TODO decide on what's valid, more complete verification is probably smart, or maybe - who are we to say :) Perhaps the USPS system?
            if let streetOne = streetOne, city = city, state = state, zip = zip
                where !streetOne.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty {
                    return true
            }
            return false
        }
    }

    func getCoordinates(callback: (coordinates: CLLocationCoordinate2D?)->()) {
        if self.valid == false {
            callback(coordinates: nil)
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.displayString, completionHandler: { (placemarks, error) in
            if let placemark = placemarks?[0] as CLPlacemark? {
                let mark = MKPlacemark(placemark: placemark)
                if let coordinates = mark.location?.coordinate {
                    // radius in meters
                    callback(coordinates: coordinates)
                    C29Log(.Debug, "Address \(self.displayString) coordinates defined \(coordinates)")
                }
            }
        })
    }
}

extension CopperAddressRecord : CopperStringDisplayRecord {
    public var displayString: String {
        get {
            var items = [String]()
            if streetOne != nil { items.append(streetOne!) }
            if streetTwo != nil { items.append(streetTwo!) }
            // Build the municipal line
            var muni = [String]()
            if city != nil { muni.append(city!) }
            if state != nil { muni.append(state!) }
            if zip != nil { muni.append(zip!) }
            let muniString = muni.joinWithSeparator(", ")
            if !muniString.isEmpty { items.append(muniString) }
            if country != nil { items.append(country!) }
            return items.joinWithSeparator("\n")
        }
    }
}


func ==(lhs: CopperAddressRecord, rhs: CopperAddressRecord) -> Bool {
    if lhs.id == rhs.id {
        return true
    }
    return lhs.streetOne == rhs.streetOne && lhs.streetTwo == rhs.streetTwo && lhs.city == rhs.city && lhs.state == rhs.state && lhs.zip == rhs.zip && lhs.country == rhs.country
}
