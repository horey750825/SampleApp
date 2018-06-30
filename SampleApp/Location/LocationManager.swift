//
//  LocationManager.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/29.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

struct PinItem {
    var route: MKRoute!
    var mapItem: MKMapItem!
}

protocol LocationManagerDelegate : NSObjectProtocol {
    func gotCurrentLocation(currentLocation : CLLocation)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let sharedInstance : LocationManager = LocationManager()
    var manager : CLLocationManager!
    var delegate : LocationManagerDelegate?
    
    var didCheckAuthorization = false
    var updating = false
    
    private override init() {
        super.init()
        DispatchQueue.main.async {
            self.manager = CLLocationManager()
            self.manager.distanceFilter = kCLLocationAccuracyNearestTenMeters
            self.manager.desiredAccuracy = kCLLocationAccuracyBest
            self.manager.delegate = self
        }
    }
    
    func getAuthorize() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedWhenInUse:
            self.startUpdatingLocation()
            return
        case .denied, .restricted:
            logger.debug("request denied")
            self.stopUpdatingLocation()
        default:
            manager.requestWhenInUseAuthorization()
            didCheckAuthorization = true
        }
    }
    
    func stopUpdatingLocation() {
        DispatchQueue.main.async {
            if self.updating {
                self.manager.stopUpdatingLocation()
                self.updating = false
            }
        }
    }
    
    func startUpdatingLocation() {
        DispatchQueue.main.async {
            if !self.updating {
                self.manager.startUpdatingLocation()
                self.updating = true
            }
        }
    }
    
    // MARK CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0]
        self.delegate?.gotCurrentLocation(currentLocation: currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        logger.debug("status \(status.rawValue)")
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            self.startUpdatingLocation()
        default:
            self.stopUpdatingLocation()
        }
    }
}
