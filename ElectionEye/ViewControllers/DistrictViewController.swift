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
import FloatingPanel

class DistrictViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    var marker: GMSMarker?
    var constituencies = [Constituency]()
    let fpc = FloatingPanelController()
    var contentVC = SearchViewController()
    var searchBar = UISearchBar()
    var pollStations = [PollStation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: 12.92, longitude: 79.19, zoom: 9.0)
        mapView.camera = camera
        
        Requests.shared.fetchConstituency { (constituencies,status)  in
            if status{
                self.constituencies = constituencies
                self.contentVC.array = constituencies
                DispatchQueue.main.async {
                    self.contentVC.searchTable.reloadData()
                }
                DispatchQueue.main.async {
                    for place in constituencies{
                        Requests.shared.geoLocation(address: place.name!, completion: { (placemark, status) in
                            if status{
                                self.markOnMap(title: place.name!, latitude: (placemark?.location?.coordinate.latitude)!, longitude: (placemark?.location?.coordinate.longitude)!)
                                print("Here")
                            }
                        })
                    }
                }
            }
        }
        
        // fpc
        
        fpc.delegate = self
        fpc.surfaceView.backgroundColor = .clear
        fpc.surfaceView.cornerRadius = 9.0
        fpc.surfaceView.shadowHidden = false
        contentVC = (storyboard?.instantiateViewController(withIdentifier: "SearchPanel") as? SearchViewController)!
        fpc.set(contentViewController: contentVC)
        fpc.track(scrollView: contentVC.searchTable)
        fpc.addPanel(toParent: self)
        fpc.move(to: .tip, animated: true)
        //map
        searchBar = contentVC.searchController.searchBar
        searchBar.delegate = self
        mapView.delegate = self
        
        mapView.animate(to: GMSCameraPosition.camera(withLatitude: 12.92, longitude: 79.19, zoom: 9.0))
        
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
    
    func markOnMap(title: String,latitude: Double, longitude:Double) {
        let marker = GMSMarker()
        let icon = UIView()
        icon.iconView(text: title)
        marker.iconView = icon
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = title
        marker.snippet = "Tamil Nadu"
        marker.map = mapView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fpc.addPanel(toParent: self, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        fpc.removePanelFromParent(animated: true)
    }
    
    @IBAction func unwindToDistrictViewController(segue:UIStoryboardSegue) { }

}

extension DistrictViewController: GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var ac_no: String?
        let alert = UIAlertController(title: "Loading", message: "Fetching \(marker.title!)'s Details", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        if let constituency = constituencies.first(where: {$0.name == marker.title}) {
            ac_no = constituency.ac_no
            pollStations.removeAll()
            Requests.shared.fetchPollStations(ac_no: ac_no!) { (pollstation, status) in
                if status{
                    for station in pollstation{
                        if station.ac_no == ac_no{
                            self.pollStations.append(station)
                        }
                    }
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: {
                            self.performSegue(withIdentifier: "detail", sender: Any?.self)
                        })
                    }
                }
            }
        } else {
            showAlert(title: "Couldn't Find", message: "Couldn't find constituency.")
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DetailDistrictViewController {
            viewController.pollStations = pollStations
        }
    }
}

extension DistrictViewController: FloatingPanelControllerDelegate{
    
}

extension DistrictViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        fpc.move(to: .full, animated: true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fpc.move(to: .tip, animated: true)
    }
}
