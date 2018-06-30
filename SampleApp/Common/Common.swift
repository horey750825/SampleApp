//
//  CommonID.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/14.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import Foundation
import UIKit

enum AuthResult {
    case success(Bool), failure(Error?)
}

struct Common {
    static let ud = UserDefaults.standard
    static let DID_SIGNIN = "DID_SIGNIN"
    static let SET_WALKING_DISTANCE = "SET_WALKING_DISTANCE"
    static let USER_REGISTER_DATA = "USER_REGISTER_DATA"
    static let USERDATA_USERID = "USERDATA_USERID"
    static let USERDATA_IDTOKEN = "USERDATA_IDTOKEN"
    static let USERDATA_GIVEN_NAME = "USERDATA_GIVEN_NAME"
    static let USERDATA_FAMILY_NAME = "USERDATA_FAMILY_NAME"
    static let USERDATA_EMAIL = "USERDATA_EMAIL"
    static let USERDATA_USER_IMAGE = "USERDATA_USER_IMAGE"
}

struct DeviceProfile {
    static let screenHeight = Double(UIScreen.main.bounds.size.height)
    static let screenWidth = Double(UIScreen.main.bounds.size.width)
}

extension String {
    func isValidDouble(maxDecimalPlaces: Int) -> Bool {
        // Use NumberFormatter to check if we can turn the string into a number
        // and to get the locale specific decimal separator.
        let formatter = NumberFormatter()
        formatter.allowsFloats = true // Default is true, be explicit anyways
        let decimalSeparator = formatter.decimalSeparator ?? "."  // Gets the locale specific decimal separator. If for some reason there is none we assume "." is used as separator.
        
        // Check if we can create a valid number. (The formatter creates a NSNumber, but
        // every NSNumber is a valid double, so we're good!)
        if formatter.number(from: self) != nil {
            // Split our string at the decimal separator
            let split = self.components(separatedBy: decimalSeparator)
            
            // Depending on whether there was a decimalSeparator we may have one
            // or two parts now. If it is two then the second part is the one after
            // the separator, aka the digits we care about.
            // If there was no separator then the user hasn't entered a decimal
            // number yet and we treat the string as empty, succeeding the check
            let digits = split.count == 2 ? split.last ?? "" : ""
            
            // Finally check if we're <= the allowed digits
            return digits.count <= maxDecimalPlaces
        }
        
        return false // couldn't turn string into a valid number
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
