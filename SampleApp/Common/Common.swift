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
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        
        let decimalSeparator = formatter.decimalSeparator ?? "."
        
        if formatter.number(from: self) != nil {
            let split = self.components(separatedBy: decimalSeparator)
            let digits = split.count == 2 ? split.last ?? "" : ""
            return digits.count <= maxDecimalPlaces
        }
        
        return false
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
