//
//  DistrictViewController.swift
//  Election-App
//
//  Created by Aritro Paul on 28/03/19.
//  Copyright © 2019 Aritropaul. All rights reserved.
//

import UIKit
import GoogleMaps
import Starscream

class DistrictViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    var marker: GMSMarker?
    var constituencies = [Constituency]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Requests.shared.fetchConstituency { (constituencies,status)  in
            if status{
                self.constituencies = constituencies
                DispatchQueue.main.async {
                }
            }
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: 12.92, longitude: 79.19, zoom: 9.0)
        mapView.camera = camera
        mapView.delegate = self
        
        mapView.layer.cornerRadius = 8
        mapView.makeCard()
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
        // Creates a marker in the center of the map.
        // Do any additional setup after loading the view.
    }
    
//    func markOnMap(title: String,latitude: Double, longitude:Double){
//        let marker = GMSMarker()
//        marker.icon = mapIconView
//        mapIconView.locationLabel.text = title
//        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        marker.title = title
//        marker.snippet = "Tamil Nadu"
//        marker.map = mapView
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? DistrictDetailViewController {
//            vc.mapPosition = self.buttonLocation
//        }
    }
    
    @IBAction func unwindToDistrictViewController(segue:UIStoryboardSegue) { }

}

extension DistrictViewController: GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.performSegue(withIdentifier: "detail", sender: Any?.self)
        return true
    }
}
