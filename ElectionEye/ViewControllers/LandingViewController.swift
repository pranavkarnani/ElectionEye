//
//  LandingViewController.swift
//  ElectionEye
//
//  Created by Pranav Karnani on 08/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import CoreLocation

class LandingViewController: UIViewController, CLLocationManagerDelegate {
    
    var status = ""
    var performSegue = false
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        let userToken = UserDefaults.standard.value(forKey: "ElectionEye_token") as? String ?? "NA"
        print(userToken)
        if userToken != "" {
            status = "bypass"
        }
        else {
            status = "toLogin"
        }
        startLocationUpdates()
        
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways: performSegue = true
            break
            case .authorizedWhenInUse,.denied,.notDetermined,.restricted:performSegue = false
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if performSegue {
            self.performSegue(withIdentifier: status, sender: Any?.self)
        }
        else {
            self.showAlert(title: "Location Privacy Alert", message: "This application requires all the users to permit location access.")
        }
    }
    
    func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last?.coordinate)
    }
}
