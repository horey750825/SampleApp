//
//  CommonID.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/14.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto
import SystemConfiguration

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
    static var didConnectNetwork = false
    
    static func showSimpleAlert(Title: String, Message: String) {
        let alert = UIAlertController(title: Title, message: Message)
        alert.show()
    }
    
    static func showNetworkWarningAlert() {
        let alert = UIAlertController(title: "Warning", message: "Please check network")
        alert.show()
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}

struct DeviceProfile {
    static let screenHeight = Double(UIScreen.main.bounds.size.height)
    static let screenWidth = Double(UIScreen.main.bounds.size.width)
}

extension String {
    
    var md5: String? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        
        let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes, CC_LONG(data.count), &hash)
            return hash
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
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
