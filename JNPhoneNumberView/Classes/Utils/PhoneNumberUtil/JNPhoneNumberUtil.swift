//
//  JNPhoneNumberUtil.swift
//  CountryPicker
//
//  Created by Hamzawy Khanfar on 07/10/2019.
//  Copyright © 2019 Hamzawy Khanfar. All rights reserved.
//

import Foundation
import libPhoneNumber_iOS

/// JNPhone Number Util
@objc public class JNPhoneNumberUtil: NSObject {
    
    /**
     Is Phone Number Valid
     - Parameter phoneNumber: phone number as string
     - Parameter defaultRegion: default region as string
     - Returns: flag to indicates
     */
    @objc public class func isPhoneNumberValid(phoneNumber: String, defaultRegion: String) -> Bool {
        
        // Init phone number util
        let phoneNumberUtil = NBPhoneNumberUtil()
        
        // Parse phone number
        if let parsedPhoneNumber = JNPhoneNumberUtil.parsePhoneNumber(phoneNumber, defaultRegion: defaultRegion) {
            
            // Check if region code is empty
            if defaultRegion.isEmpty {
                return phoneNumberUtil.isValidNumber(parsedPhoneNumber)
            }
            
            return (phoneNumberUtil.isValidNumber(parsedPhoneNumber) && phoneNumberUtil.isValidNumber(forRegion: parsedPhoneNumber, regionCode: defaultRegion))
        }
        
        return false
    }
    
    /**
     Parse Phone Number
     - Parameter phoneNumber: phone number as string
     - Parameter defaultRegion: default region as string
     - Returns: parsed phone number as NBPhoneNumber
     */
    @objc public class func parsePhoneNumber(_ phoneNumber: String, defaultRegion: String) -> NBPhoneNumber? {
        
        // Modified phone number
        var modifiedPhoneNumber = phoneNumber
        
        // Check prefix
        if modifiedPhoneNumber.prefix(2) == "00" {
            
            // remove zeros prefix
            modifiedPhoneNumber.removeSubrange(modifiedPhoneNumber.startIndex...modifiedPhoneNumber.index(modifiedPhoneNumber.startIndex, offsetBy: 1))
            
            modifiedPhoneNumber = "+"+modifiedPhoneNumber
        }
        
        // Init phone number util
        let phoneNumberUtil = NBPhoneNumberUtil()
        
        // Parse phone number
        do {
            // Parse phone number
            let phoneNumber = try phoneNumberUtil.parse(modifiedPhoneNumber, defaultRegion: defaultRegion)
            
            // Return phone number
            return phoneNumber
        } catch {
            
            // National number
            var nationalNumber: NSString? = nil
            
            // Dial code
            let dialCode = phoneNumberUtil.extractCountryCode(modifiedPhoneNumber, nationalNumber: &nationalNumber)
            
            // Check if dial code or national phone number not detected
            if (dialCode?.description ?? "").isEmpty  || nationalNumber == nil {
                return  nil
            }
            
            // Create phone number object
            let nbPhoneNumber = NBPhoneNumber()
            
            // Set dial code
            nbPhoneNumber.countryCode = dialCode
            
            // Check if national number not empty
            if nationalNumber!.length > 0 {
                
                // Convert NSString To String
                let stringNationalNumber: String = nationalNumber! as String
                
               // National Phone Number
                var nationalPhoneNumber: NSNumber
                
                if let integerValue = Int64(stringNationalNumber) {
                    // Convert national number from string to NSNumber
                     nationalPhoneNumber = NSNumber(value: integerValue)
                }else{
                     // Convert national number from NSString to NSNumber
                    nationalPhoneNumber = NSNumber(value: nationalNumber!.floatValue)
                }
          
                
                // set national number
                nbPhoneNumber.nationalNumber = nationalPhoneNumber
            }
            
            return nbPhoneNumber
        }
    }
}
