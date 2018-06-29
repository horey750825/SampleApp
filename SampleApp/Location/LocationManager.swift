//
//  LocationManager.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/29.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit
import CoreLocation

public protocol LocationManagerDelegate {
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let sharedInstance : LocationManager = LocationManager()
    let manager = CLLocationManager()
    var delegate : LocationManagerDelegate?
    
    var didCheckAuthorization = false
    
    private override init() {
        super.init()
    }
    
    func getAuthorize() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedWhenInUse:
            return
        case .denied, .restricted:
            logger.debug("request denied")
        default:
            manager.requestWhenInUseAuthorization()
            didCheckAuthorization = true
        }
    }
    
    // MARK CLLocationManagerDelegate
}
