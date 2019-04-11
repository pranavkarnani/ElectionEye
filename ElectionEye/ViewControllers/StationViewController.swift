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
    var pollingStation: Station?
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var nativeNameLabel: UILabel!
    @IBOutlet weak var zoneNumber: UILabel!
    @IBOutlet weak var boothNumbers: UILabel!
    @IBOutlet weak var stationNumber: UILabel!
    @IBOutlet weak var stationBackView: UIView!
    @IBOutlet weak var officerName: UILabel!
    @IBOutlet weak var vulnerableView: UIView!
    @IBOutlet weak var vulStation: UILabel!
    @IBOutlet weak var vulType: UILabel!
    @IBOutlet weak var boothDetails: UILabel!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var stationAddressLabel: UILabel!
    @IBOutlet weak var officerRankLabel: UILabel!
    @IBOutlet weak var officerContactLabel: UILabel!
    @IBOutlet weak var policeStationLabel: UILabel!
    @IBOutlet weak var sectionalOfficerLabel: UILabel!
    @IBOutlet weak var conductNumberLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        mapSetup()
        print(pollingStation)
        markOnMap(title: (pollingStation?.location_name)!, latitude: Double(exactly:  (pollingStation?.latitude)!)!, longitude: Double(exactly: (pollingStation?.longitude)!)!)
        mapView.animate(to: GMSCameraPosition.camera(withLatitude: Double(exactly:  (pollingStation?.latitude)!)!, longitude: Double(exactly: (pollingStation?.longitude)!)!, zoom: 12.0))
        locationNameLabel.text = pollingStation?.location_name
        nativeNameLabel.text = pollingStation?.location_name_native
        zoneNumber.text = pollingStation?.zone_no
        boothNumbers.text = pollingStation?.booths
        stationNumber.text = String(describing: (pollingStation?.stn_no!)!)
        stationBackView.layer.cornerRadius = stationBackView.frame.height/2
        officerName.text = pollingStation?.police_officer_name
        stationNameLabel.text = pollingStation?.name
        stationAddressLabel.text = pollingStation?.stn_address
        officerRankLabel.text = pollingStation?.officer_rank
        officerContactLabel.text = pollingStation?.officer_contact_number
        policeStationLabel.text = pollingStation?.police_station
        sectionalOfficerLabel.text = pollingStation?.sec_officer_names
        conductNumberLabel.text = pollingStation?.conduct_number
        vulnerableView.layer.cornerRadius = 8
        
        if (pollingStation?.is_vulnerable)!{
            vulnerableView.alpha = 1
            boothDetails.text = pollingStation?.vulnerable_booth_detail?[0].vul_habitats
            vulType.text = pollingStation?.vulnerable_booth_detail![0].vul_types
            vulStation.text = "\((pollingStation?.vulnerable_booth_detail![0].stn_no)!)"
        }
        else{
            vulnerableView.alpha = 0
            boothDetails.alpha = 0
            vulType.alpha = 0
            vulStation.alpha = 0
        }
        // Do any additional setup after loading the view.
    }
    
    
    func setup(){
        backButton.makeCard()
        backButton.layer.cornerRadius = backButton.frame.height/2
    }
    
    func mapSetup(){
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(pollingStation?.latitude ?? 12.93), longitude: CLLocationDegrees(pollingStation?.longitude ?? 79.19), zoom: 12.0)
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
    
    func markOnMap(title: String,latitude: Double, longitude:Double) {
        let marker = GMSMarker()
        marker.icon = UIImage(named: "icon")
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = title
        marker.snippet = "Tamil Nadu"
        marker.map = mapView
    }
    
    @IBAction func callTapped(_ sender: Any) {
        if let url = URL(string: "tel://\(pollingStation!.polling_location_incharge_number!)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
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
