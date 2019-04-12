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
    var userRole : String?
    var fromModal = false
    
    let fpc = FloatingPanelController()
    var contentVC = StationSearchViewController()
    var searchBar = UISearchBar()
    
    var timer: Timer?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetup()
        contentVC = (storyboard?.instantiateViewController(withIdentifier: "stationSearch") as? StationSearchViewController)!
        
        for pollStation in pollStations{
            markOnMap(title: String(describing: pollStation.stn_no!), latitude: pollStation.latitude!, longitude: pollStation.longitude!)
        }
        setup()
        fpcSetup()
        
        self.userRole = UserDefaults.standard.string(forKey: "ElectionEye_role")
//        print(self.userRole!)
        // Do any additional setup after loading the view.
    }
    
    @objc func refreshMap() {
        print("Refreshing")
        mapView.clear()
        for pollStation in pollStations{
            markOnMap(title: String(describing: pollStation.stn_no!), latitude: pollStation.latitude!, longitude: pollStation.longitude!)
        }
        if userRole == "0"{
                for location in locations{
                    print(location)
                    carOnMap(zone_no: location.zone_no! , latitude: Double(location.lat!), longitude: Double(location.lng!))
                }
        
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.refreshMap), userInfo: nil, repeats: true)
        setup()
        fpcSetup()
    }
    
    func fpcSetup(){
        fpc.delegate = self
        fpc.surfaceView.backgroundColor = .clear
        fpc.surfaceView.cornerRadius = 9.0
        fpc.surfaceView.shadowHidden = false
        fpc.set(contentViewController: contentVC)
        fpc.track(scrollView: contentVC.searchTable)
        fpc.addPanel(toParent: self)
        fpc.move(to: .tip, animated: true)
        //map
        searchBar = contentVC.searchController.searchBar
        searchBar.delegate = self
        contentVC.array = pollStations
        contentVC.searchTable.reloadData()
    }
    
    func setup(){
        backButton.makeCard()
        backButton.layer.cornerRadius = backButton.frame.height/2
    }
    
    func mapSetup(){
        let camera = GMSCameraPosition.camera(withLatitude: pollStations[0].latitude ?? 12.92, longitude: pollStations[0].longitude ?? 79.19, zoom: 12.0)
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
    
    func carOnMap(zone_no: String,latitude: Double, longitude:Double) {
        let marker = GMSMarker()
        marker.icon = UIImage(named: "Car")
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = zone_no
        marker.map = mapView
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        if fromModal{
            self.dismiss(animated: true, completion: nil)
        }
        else{
            self.performSegue(withIdentifier: "unwinded", sender: Any?.self)
        }
    }
    
    @IBAction func unwindToDetailDistrictViewController(segue:UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        timer?.invalidate()
        if let viewController = segue.destination as? StationViewController {
            viewController.pollingStation = stationDetails
        }
    }
    
}

extension DetailDistrictViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let index = Int(marker.title!) ?? 0
        let poll = pollStations[index]
        print("LOOK HERE")
        print(poll.stn_no!)
        print("RIGHT HERE")
        DataHandler.shared.retrieveStations(ac_no: poll.ac_no!, stn_no: poll.stn_no!) { (stations, status) in
            if status{
                print(stations)
                self.stationDetails = stations[0]
                print(self.stationDetails)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "station", sender: Any?.self)
                }
                
                
            }
            else{
                self.showAlert(title: "Couldn't Fetch", message: "Fuck.")
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
