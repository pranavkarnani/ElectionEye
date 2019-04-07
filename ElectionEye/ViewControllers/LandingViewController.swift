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
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let userToken = UserDefaults.standard.value(forKey: "ElectionEye_token") as? String ?? "NA"
        print(userToken)
        if userToken != "" {
            status = "bypass"
            self.startLocationUpdates()
        }
        else {
            status = "toLogin"
            self.startLocationUpdates()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.performSegue(withIdentifier: status, sender: Any?.self)
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
