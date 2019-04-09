//
//  DetailDistrictViewController.swift
//  ElectionEye
//
//  Created by Aritro Paul on 08/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import GoogleMaps
import FloatingPanel

class DetailDistrictViewController: UIViewController {

    var pollStations = [PollStation]()
    var stations = [Station]()
    var stationDetails = Station()
    
    let fpc = FloatingPanelController()
    var contentVC = StationSearchViewController()
    var searchBar = UISearchBar()
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetup()
        
        Requests.shared.fetchStation() { (station, status) in
            if status{
                self.stations = station
                print("Done")
            }
        }
        
        for pollStation in pollStations{
            markOnMap(title: String(describing: pollStation.stn_no!), latitude: pollStation.latitude!, longitude: pollStation.longitude!)
        }
        setup()
        fpcSetup()
        // Do any additional setup after loading the view.
    }
    
    func fpcSetup(){
        fpc.delegate = self
        fpc.surfaceView.backgroundColor = .clear
        fpc.surfaceView.cornerRadius = 9.0
        fpc.surfaceView.shadowHidden = false
        contentVC = (storyboard?.instantiateViewController(withIdentifier: "stationSearch") as? StationSearchViewController)!
        fpc.set(contentViewController: contentVC)
        fpc.track(scrollView: contentVC.searchTable)
        fpc.addPanel(toParent: self)
        fpc.move(to: .tip, animated: true)
        //map
        searchBar = contentVC.searchController.searchBar
        searchBar.delegate = self
        contentVC.array = pollStations
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
            viewController.pollingStation = stationDetails
        }
    }
    
}

extension DetailDistrictViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let index = Int(marker.title!)!
        let poll = pollStations[index]
        for station in self.stations{
            if station.ac_no == poll.ac_no{
                if station.stn_no == poll.stn_no{
                    self.stationDetails = station
                    self.performSegue(withIdentifier: "station", sender: Any?.self)
                }
            }
        }
        return true
    }
}

extension DetailDistrictViewController: FloatingPanelControllerDelegate{

}

extension DetailDistrictViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        fpc.move(to: .full, animated: true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fpc.move(to: .tip, animated: true)
    }
    
}
