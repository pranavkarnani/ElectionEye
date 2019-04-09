//
//  DetailDistrictViewController.swift
//  ElectionEye
//
//  Created by Aritro Paul on 08/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailDistrictViewController: UIViewController {

    var pollStations = [PollStation]()
    var station = Station()
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetup()
        for pollStation in pollStations{
            markOnMap(title: String(describing: pollStation.stn_no!), latitude: pollStation.latitude!, longitude: pollStation.longitude!)
        }
        setup()
        // Do any additional setup after loading the view.
    }
    
    func setup(){
        backButton.makeCard()
        backButton.layer.cornerRadius = backButton.frame.height/2
    }
    
    func mapSetup(){
        let camera = GMSCameraPosition.camera(withLatitude: 12.92, longitude: 79.19, zoom: 12.0)
        mapView.camera = camera
        mapView.clear()
        mapView.delegate = self
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
    }
    
    func markOnMap(title: String,latitude: Double, longitude:Double) {
        let marker = GMSMarker()
        marker.icon = UIImage(named: "icon")
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = title
        marker.snippet = "Tamil Nadu"
        marker.map = mapView
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "unwinded", sender: Any?.self)
    }
    
    @IBAction func unwindToDetailDistrictViewController(segue:UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? StationViewController {
            viewController.pollingStation = station
        }
    }
    
}

extension DetailDistrictViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let index = Int(marker.title!)!
        let poll = pollStations[index]
        Requests.shared.fetchStation(stn_no: poll.stn_no!) { (station, status) in
            if status{
                self.station = station
                self.performSegue(withIdentifier: "station", sender: Any?.self)
            }
        }
        
        return true
    }
}
