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
    var stations = Station()
    var userRole : Bool = false
    var fromModal = false
    var constituency = Constituency()
    
    let fpc = FloatingPanelController()
    var contentVC = StationSearchViewController()
    var searchBar = UISearchBar()
    
    var timer: Timer?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if fromModal{
            let ac_no = constituency.ac_no
            DataHandler.shared.retrievePollingStations(ac_no: ac_no!) { (pollstation, status) in
                if status{
                    DispatchQueue.main.async {
                        self.pollStations = pollstation
                        self.contentVC = (self.storyboard?.instantiateViewController(withIdentifier: "stationSearch") as? StationSearchViewController)!
                        
                        for pollStation in self.pollStations{
                            self.markOnMap(station: pollStation, latitude: pollStation.latitude!, longitude: pollStation.longitude!)
                        }
                        
                        self.mapSetup()
                        self.fpcSetup()
                    }
                }
            }
        }
        else{
            contentVC = (storyboard?.instantiateViewController(withIdentifier: "stationSearch") as? StationSearchViewController)!
            
            for pollStation in pollStations{
                markOnMap(station: pollStation, latitude: pollStation.latitude!, longitude: pollStation.longitude!)
            }
            
            mapSetup()
            fpcSetup()
        }
        
        self.userRole = UserDefaults.standard.value(forKey: "ElectionEye_role") as? Bool ?? false
        print("🙋🏻‍♂️ \(self.userRole)")
        // Do any additional setup after loading the view.
    }
    
    @objc func refreshMap() {
        mapView.clear()
        for pollStation in pollStations{
            markOnMap(station: pollStation, latitude: pollStation.latitude!, longitude: pollStation.longitude!)
        }
        if userRole {
                for location in locations{
                    print("🚔 \(location)")
                    carOnMap(zone_no: location.zone_no! , latitude: Double(location.lat!), longitude: Double(location.lng!))
                }
        
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.refreshMap), userInfo: nil, repeats: true)
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
        pollStations.sort{ (this, that) -> Bool in
            return sortFunc(num1: this.stn_no!, num2: that.stn_no!)
        }
        contentVC.array = pollStations
        contentVC.searchTable.reloadData()
    }
    
    func sortFunc(num1: Int, num2: Int) -> Bool {
        return num1 < num2
    }
    
    override func viewDidLayoutSubviews() {
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
                print("❌ Unable to find style.json")
            }
        } catch {
            print("❌ One or more of the map styles failed to load. \(error)")
        }
    }
    
    func markOnMap(station: PollStation ,latitude: Double, longitude:Double) {
        let marker = GMSMarker()
        DataHandler.shared.retrieveStations(ac_no: station.ac_no!, stn_no: station.stn_no!) { (stations, status) in
            if status {
                if stations.is_vulnerable == true {
                    marker.icon = UIImage(named: "Vul")
                    marker.title = "\(stations.location_no!)"
                }
                else{
                    marker.icon = UIImage(named: "Safe")
                    marker.title = "\(stations.location_no!)"
                }
            }
        }
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
            viewController.pollingStation = stations
        }
    }
    
}

extension DetailDistrictViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let index = Int(marker.title!)
        var poll = PollStation()
        if let polls = pollStations.first(where: {$0.stn_no == index}) {
            poll = polls
        } else {
            // item could not be found
        }
        DataHandler.shared.retrieveStations(ac_no: poll.ac_no!, stn_no: poll.stn_no!) { (stations, status) in
            if status {
                self.stations = stations
                if stations.is_vulnerable == true{
                    DataHandler.shared.retrieveVulneribility(ac_no: poll.ac_no!, stn_no: poll.stn_no!, completion: { (booths, status) in
                        if status{
                            self.stations.vulnerable_booth_detail = booths
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "station", sender: Any?.self)
                            }
                        }
                        else{
                            print("❌ Couldn't fetch Vulnerable Booths")
                        }
                    })
                }
                else{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "station", sender: Any?.self)
                    }
                }
            }
            else{
                self.showAlert(title: "Couldn't Fetch", message: "")
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
