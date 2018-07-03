//
//  MainViewController.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/08.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController, HealthDelegate, LocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, UITextFieldDelegate {

    @IBOutlet weak var buttonComeBackToCurrent: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelMain: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    
    var didAuthorize = false
    var currentLocation : CLLocation!
    var selectedPin: MKAnnotationView!
    var pinItemList = [PinItem]()
    var gotFIrstTimePostion = false
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
        
        let gestureLongPress = UILongPressGestureRecognizer(target: self, action: #selector(self.actionForMap(gestureRecognizer:)))
        mapView.addGestureRecognizer(gestureLongPress)
        
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
            } else {
                LocationManager.sharedInstance.startUpdatingLocation()
            }
            setLabelDescription()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        LocationManager.sharedInstance.stopUpdatingLocation()
    }
    
    func prepareSetting() {
        
        //set UI
        setLabel()
        buttonComeBackToCurrent.addTarget(self, action: #selector(tapButtonComeBackToCurrent(sender:)), for: .touchUpInside)
    }
    
    @objc func actionForMap(gestureRecognizer: UILongPressGestureRecognizer){
        clearAllPinsAndOverlays()
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let newCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        self.mapView.addAnnotation(annotation)
    }
    
    @objc func tapButtonComeBackToCurrent(sender: UIButton) {
        self.mapView.centerCoordinate = self.currentLocation.coordinate
    }
    
    func setLabel() {
        self.labelMain.text = "Please Search"
        setLabelDescription()
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
    
    func setLabelDescription() {
        if !HealthManager.sharedInstance.personalProfile.didCheckDistanceEveryday {
            self.labelDescription.text = "..."
            return
        }
        let distance = HealthManager.sharedInstance.getShouldWalkDistance()
        if distance < 0 {
            self.labelDescription.text = "You have finished the target"
        } else {
            self.labelDescription.text = "Still has \(HealthManager.sharedInstance.getShouldWalkDistance().rounded(toPlaces: 2)) km"
        }
    }
    
    func clearAllPinsAndOverlays() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
        self.pinItemList.removeAll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // #MARK - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return replacementText.isValidDouble(maxDecimalPlaces: 2)
    }

    // #MARK - HealthDelegate
    func finishPersonalProfile() {
        HealthManager.sharedInstance.didGetProfile = true
        logger.debug("\(HealthManager.sharedInstance.personalProfile.toString())")
        DispatchQueue.main.async {
            self.labelMain.text = "distance today = \(HealthManager.sharedInstance.personalProfile.walkingDistance.rounded(toPlaces: 2)) km"
            self.labelMain.sizeToFit()
            self.setLabelDescription()
        }
    }
    
    // #MARK - LocationManagerDelegate
    func gotCurrentLocation(currentLocation: CLLocation) {
//        logger.debug("location \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        DispatchQueue.main.async {
            if !self.gotFIrstTimePostion {
                self.mapView.centerCoordinate = currentLocation.coordinate
                self.gotFIrstTimePostion = true
            }
            self.currentLocation = currentLocation
                        
            // show the distance check alert
            if !HealthManager.sharedInstance.personalProfile.didCheckDistanceEveryday {
                let alert = UIAlertController(title: "Set Distance", message: "Please set only by numberic(km)", preferredStyle: .alert)
                alert.addTextField(text: "", placeholder: "set the distnce(x.xx) you want", editingChangedTarget: nil, editingChangedSelector: nil)
                alert.textFields?.first?.delegate = self
                alert.addAction(title: "Cancel", style: .cancel, isEnabled: true, handler: nil)
                alert.addAction(title: "OK", style: .default, isEnabled: true, handler: { (action) in
                    let inputText = alert.textFields!.first!.text!
                    if !inputText.isEmpty {
                        HealthManager.sharedInstance.setDistanceEverydat(Double(inputText)!)
                        self.setLabelDescription()
                    }
                    logger.debug("\(inputText)")
                })
                alert.show()
            }
        }
    }
    
    // #MARK - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.clearAllPinsAndOverlays()
        
        let request = MKLocalSearchRequest()
        request.region = self.mapView.region
        request.naturalLanguageQuery = searchBar.text
        
        let mySearch = MKLocalSearch(request: request)
        
        mySearch.start { (response, error) in
            if error != nil {
                logger.debug("\(error!.localizedDescription)")
            } else if response!.mapItems.count > 0 {
                for item in response!.mapItems {
//                    logger.debug("\(item.name!)")
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
        searchBar.clear()
        self.clearAllPinsAndOverlays()
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

