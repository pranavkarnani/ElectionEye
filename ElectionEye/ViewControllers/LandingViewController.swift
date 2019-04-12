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
    var loginCheck = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.pausesLocationUpdatesAutomatically = false
        
        loginCheck = UserDefaults.standard.value(forKey: "ElectionEye_login") as? Int ?? 0
        print(loginCheck)
        
        if Reachability.isConnectedToNetwork() {
            if  loginCheck == 4 {
                status = "bypass"
            }
            else {
                status = "toLogin"
            }
        }
        else {
            self.showAlert(title: "Connection Error", message: "You are not connected to the internet")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Requests.shared.sendLocationData(coordinates: (locations.last?.coordinate)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            performSegue = true
            transition()
        }
    }
    
    func transition() {
        if performSegue {
            if status == "bypass" {
                Requests.shared.setupSockets()
                self.performSegue(withIdentifier: status, sender: Any?.self)
            }
            else {
                self.performSegue(withIdentifier: status, sender: Any?.self)
            }
        }
        else {
            self.showAlert(title: "Location Privacy Alert", message: "This application requires all the users to permit location access.")
        }
    }
}
