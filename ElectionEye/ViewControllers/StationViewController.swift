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
    var pollingStation = Station()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        mapSetup()
        print(pollingStation)
        tableView.delegate = self
        tableView.dataSource = self

        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(pollingStation.latitude ?? 12.93), longitude: CLLocationDegrees(pollingStation.longitude ?? 79.19), zoom: 12.0)
        markOnMap(station: pollingStation, latitude: CLLocationDegrees(pollingStation.latitude ?? 12.93), longitude: CLLocationDegrees(pollingStation.longitude ?? 79.19))
        mapView.camera = camera
    }
    
    func setup(){
        
    }
    
    override func viewDidLayoutSubviews() {
        backButton.makeCard()
        backButton.layer.cornerRadius = backButton.frame.height/2
    }
    
    func mapSetup(){
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
    
    func markOnMap(station: Station,latitude: Double, longitude:Double) {
        let marker = GMSMarker()
        if station.is_vulnerable ?? false{
            marker.icon = UIImage(named: "Vul")
        }
        else{
            marker.icon = UIImage(named: "Safe")
        }
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = station.location_name
        marker.snippet = "Tamil Nadu"
        marker.map = mapView
    }
    
    @IBAction func callTapped(_ sender: Any) {
        if let url = URL(string: "tel://\(pollingStation.officer_contact_number!)"), UIApplication.shared.canOpenURL(url) {
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

extension StationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = pollingStation.vulnerable_booth_detail?.count{
            return 6 + count
        }
        else{
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as! FirstTableViewCell
            cell.locationName.text = pollingStation.location_name
            cell.nativeName.text = pollingStation.location_name_native
            cell.stationNum.text = String(describing: pollingStation.location_no!)
            return cell
        }
        if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2") as! SecondTableViewCell
            cell.stationName.text = pollingStation.name
            cell.stationAddress.text = pollingStation.stn_address
            return cell
        }
        if indexPath.row == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3") as! ThirdTableViewCell
            cell.zoneNumber.text = pollingStation.zone_no
            cell.boothsNumber.text = pollingStation.booths
            return cell
        }
        if indexPath.row == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell4") as! FourthTableViewCell
            cell.officerContactNumber.text = pollingStation.officer_contact_number
            cell.officerName.text = pollingStation.police_officer_name
            cell.officerRank.text = pollingStation.officer_rank
            if pollingStation.is_vulnerable == true{
                cell.vulnerableView.alpha = 1
            }
            else{
                cell.vulnerableView.alpha = 0
            }
            return cell
        }
        if indexPath.row == 4{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell5") as! FifthTableViewCell
            cell.policeStationDetails.text = pollingStation.police_station
            return cell
        }
        if pollingStation.is_vulnerable == true{
            let vul = pollingStation.vulnerable_booth_detail?.count
            print(vul)
            if indexPath.row < 5+vul!{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell6") as! SixthTableViewCell
                cell.vulBoothDetails.text = pollingStation.vulnerable_booth_detail![indexPath.row-5].vul_habitats
                cell.vulStations.text = pollingStation.vulnerable_booth_detail![indexPath.row-5].stn_name
                cell.vulType.text = pollingStation.vulnerable_booth_detail![indexPath.row-5].vul_types
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell7") as! SeventhTableViewCell
                cell.secOfficerName.text = pollingStation.sec_officer_names
                cell.ConductNumber.text = pollingStation.conduct_number
                return cell
            }
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell7") as! SeventhTableViewCell
            cell.secOfficerName.text = pollingStation.sec_officer_names
            cell.ConductNumber.text = pollingStation.conduct_number
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 175
        }
        if indexPath.row == 3{
            return 120
        }
        if indexPath.row == 5{
            return 250
        }
        else{
            return 80
        }
    }
    
    
}
