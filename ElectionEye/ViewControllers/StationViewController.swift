//
//  StationViewController.swift
//  
//
//  Created by Aritro Paul on 09/04/19.
//

import UIKit
import GoogleMaps

class StationViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    var pollingStation: PollStation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        mapSetup()
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
    
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindDetail", sender: Any?.self)
    }
    
}

extension StationViewController: GMSMapViewDelegate{
    
}

//extension StationViewController: UITableViewDelegate, UITableViewDataSource{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        //
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        //
//    }
//    
//    
//}
