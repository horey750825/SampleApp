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
    @IBOutlet weak var labelMain: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    
    var didAuthorize = false
    var currentLocation : CLLocation!
    var selectedPin: MKAnnotationView!
    let spanDigit = 0.02
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mapView.showsUserLocation = true
        HealthManager.sharedInstance.delegate = self
        LocationManager.sharedInstance.delegate = self
        mapView.delegate = self
        searchBar.delegate = self
        
        //map
        let span = MKCoordinateSpan(latitudeDelta: spanDigit, longitudeDelta: spanDigit)
        let region = MKCoordinateRegion(center: self.mapView.centerCoordinate, span: span)
        self.mapView.region = region
        
        // UI
        prepareSetting()
        
        logger.debug()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !Common.ud.bool(forKey: Common.DID_SIGNIN) {
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
    }
    
    func setLabel() {
        self.labelMain.text = "Please Search"
        self.labelDescription.text = "..."
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
        DispatchQueue.main.async {
            self.labelMain.text = "walking distance today = \(HealthManager.sharedInstance.personalProfile.walkingDistance) km"
            self.labelMain.sizeToFit()
        }
    }
    
    // #MARK - LocationManagerDelegate
    func gotCurrentLocation(currentLocation: CLLocation) {
//        logger.debug("location \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        DispatchQueue.main.async {
            self.mapView.centerCoordinate = currentLocation.coordinate
            self.currentLocation = currentLocation
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
                    pin.subtitle = item.phoneNumber
                    self.mapView.addAnnotation(pin)
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    // #MARK - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        self.selectedPin = view
        let toItem = MKMapItem(placemark: MKPlacemark(coordinate: view.annotation!.coordinate))
        let fromItem = MKMapItem(placemark: MKPlacemark(coordinate: self.currentLocation.coordinate))
        
        let request = MKDirectionsRequest()
        request.source = fromItem
        request.destination = toItem
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let myDirection = MKDirections(request: request)
        myDirection.calculate { (response, error) in
            if error != nil || response!.routes.isEmpty {
                return
            }
            
            let route = response!.routes[0]
            let distance = String(format: "%.2f", route.distance / 1000)
            self.labelDescription.text = "\(distance) km, \(Int(route.expectedTravelTime) / 60) mins"
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.add(route.polyline)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let route = overlay as! MKPolyline
        let render = MKPolylineRenderer(polyline: route)
        render.lineWidth = 4
        render.strokeColor = UIColor.cyan
        return render
    }
}

