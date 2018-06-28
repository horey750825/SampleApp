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

struct SettingID {
    static let DID_SIGNIN = "DID_SIGNIN"
    static let USER_REGISTER_DATA = "USER_REGISTER_DATA"
}

struct UserDataID {
    static let USERID = "USERID"
    static let IDTOKEN = "IDTOKEN"
    static let GIVEN_NAME = "GIVEN_NAME"
    static let FAMILY_NAME = "FAMILY_NAME"
    static let EMAIL = "EMAIL"
    static let USER_IMAGE = "USER_IMAGE"
}

struct DeviceProfile {
    static let screenHeight = Double(UIScreen.main.bounds.size.height)
    static let screenWidth = Double(UIScreen.main.bounds.size.width)
}
