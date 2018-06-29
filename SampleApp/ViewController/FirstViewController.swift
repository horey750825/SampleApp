//
//  FirstViewController.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/08.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit
import MapKit

class FirstViewController: UIViewController, HealthDelegate, LocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var didAuthorize = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mapView.showsUserLocation = true
        HealthManager.sharedInstance.delegate = self
        LocationManager.sharedInstance.delegate = self
        mapView.delegate = self
        searchBar.delegate = self
        logger.debug()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !CommonManager.sharedInstance.ud.bool(forKey: SettingID.DID_SIGNIN) {
            present(LoginViewController(), animated: true, completion: nil)
        } else {
            if !didAuthorize {
                self.getAllAuthorize()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        LocationManager.sharedInstance.stopUpdatingLocation()
    }
    
    func prepareSetting() {
        
        //set UI
        setLabel()
        
        if let imageUrl = CommonManager.sharedInstance.ud.url(forKey: UserDataID.USER_IMAGE) {
            let imageData = NSData(contentsOf: imageUrl)
            CommonManager.sharedInstance.imageForUser = UIImage(data: imageData! as Data)!
        }
    }
    
    func setLabel() {
        if let userData = CommonManager.sharedInstance.ud.dictionary(forKey: SettingID.USER_REGISTER_DATA) {
            var userName = userData[UserDataID.GIVEN_NAME] as! String
            userName += " "
            userName += userData[UserDataID.FAMILY_NAME] as! String
            userNameLabel.text = userName
        } else {
            userNameLabel.text = "Hi"
        }
    }
    
    func getAllAuthorize() {
        //get user information
        HealthManager.sharedInstance.authorizeHealthKit(completion: { result in
            switch result {
            case .success(let granted) :
                if granted {
                    logger.debug("access is granted")
                    if !HealthManager.sharedInstance.didGetProfile {
                        HealthManager.sharedInstance.getPersonalProfile()
                    }
                } else {
                    logger.debug("access is denied")
                }
            case .failure(let error) :
                logger.debug("access error \(error!.localizedDescription)")
            }
            if !LocationManager.sharedInstance.didCheckAuthorization {
                LocationManager.sharedInstance.getAuthorize()
            }
        })
        
        self.didAuthorize = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #MARK - HealthDelegate
    func finishPersonalProfile() {
        HealthManager.sharedInstance.didGetProfile = true
        logger.debug("\(HealthManager.sharedInstance.personalProfile.toString())")
    }
    
    // #MARK - LocationManagerDelegate
    func gotCurrentLocation(currentLocation: CLLocation) {
        logger.debug("location \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        DispatchQueue.main.async {
            self.mapView.centerCoordinate = currentLocation.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: self.mapView.centerCoordinate, span: span)
            self.mapView.region = region
        }
    }
    
    // #MARK - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        
        let request = MKLocalSearchRequest()
        request.region = self.mapView.region
        request.naturalLanguageQuery = searchBar.text
        
        let mySearch = MKLocalSearch(request: request)
        
        mySearch.start { (response, error) in
            if error != nil {
                logger.debug("\(error!.localizedDescription)")
            } else if response!.mapItems.count > 0 {
                for item in response!.mapItems {
                    logger.debug("\(item.name!)")
                    let pin = MKPointAnnotation()
                    pin.coordinate = item.placemark.coordinate
                    pin.title = item.name
                    self.mapView.addAnnotation(pin)
                }
            }
        }
    }
}

