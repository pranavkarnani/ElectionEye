//
//  Requests.swift
//  ElectionEye
//
//  Created by Pranav Karnani on 06/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import Foundation
import FirebaseAuth
import Starscream
import CoreLocation
import SwiftyJSON

class Requests : WebSocketDelegate {
    
    static let shared : Requests = Requests()
    
    func numberVerification(number: String, completion : @escaping(String,Bool) -> ()) {
        
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { (verificationID, error) in
            if error != nil {
                completion("",false)
            }
            else {
                guard let verificationID = verificationID else { return }
                completion(verificationID,true)
            }
        }
    }
    
    func OTPVerification(otp : String, verificationID: String, completion: @escaping(Bool) -> ()) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: otp)
        Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
            if error != nil {
                completion(false)
            }
            else {
                completion(true)
            }
        }
    }
    
    func performLogin(phone: String, completion : @escaping(UserRoles,Bool) -> ()) {
        
        guard let loginURL = loginURL else { return }

        var details = UserLogin()
        details.phone_no = phone
        let loginDetails = try? JSONEncoder().encode(details)
        var userDetails = UserRoles()
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = loginDetails
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(userDetails,false)
            }
            else {
                guard let data = data else { return }
                
                do {
                    userDetails = try JSONDecoder().decode(UserRoles.self, from: data)
                    completion(userDetails,true)
                } catch {
                    print("❗️ \(error.localizedDescription)")
                    completion(userDetails,false)
                }
                completion(userDetails,true)
            }
        }.resume()
    }
    
    func getZones(completion : @escaping([Zones],Bool) -> ()) {
        var zones : [Zones] = []
        guard let fetchZonesURL = fetchZonesURL else { return }
        URLSession.shared.dataTask(with: fetchZonesURL) { (data, response, error) in
            if error != nil {
                completion(zones,false)
            }
            else {
                do {
                    guard let data = data else { return }
                    zones = try JSONDecoder().decode([Zones].self, from: data)
                    completion(zones,true)
                } catch {
                    print("❗️ \(error.localizedDescription)")
                    completion(zones,false)
                }
            }
        }.resume()
    }
    
    func fetchConstituency(completion : @escaping(Bool) -> ()) {
        guard let constituencyURL = constituencyURL else { return }
        var constituencies: [Constituency] = []
        URLSession.shared.dataTask(with: constituencyURL) { (data, response, error) in
            
            guard let data = data else {
                completion(false)
                return
            }
            
            do {
                constituencies = try JSONDecoder().decode([Constituency].self, from: data)
                DataHandler.shared.persistConstituencies(constituency: constituencies)
                completion(true)
            } catch {
                completion(false)
            }
        }.resume()
    }
    
    func fetchPollStations(completion : @escaping(Bool)->()){
        guard let pollURL = pollURL else { return }
        var pollStations: [PollStation] = []
        URLSession.shared.dataTask(with: pollURL) { (data, response, error) in
            
            guard let data = data else {
                completion(false)
                return
            }
            
            do {
                pollStations = try JSONDecoder().decode([PollStation].self, from: data)
                DataHandler.shared.persistPollingStations(pollStations: pollStations)
                completion(true)
            } catch {
                completion(false)
            }
        }.resume()
    }
    
    func fetchStation(completion : @escaping(Bool)->()){
        var stationArray = [Station]()
        guard let stationURL = stationURL else { return }
        URLSession.shared.dataTask(with: stationURL) { (data, response, error) in
            guard let data = data else {
                completion(false)
                return
            }
            do {
                stationArray = try JSONDecoder().decode(StationMaster.self, from: data).stations!
                DataHandler.shared.persistStations(stations : stationArray)
                DataHandler.shared.persistVulneribility(stations : stationArray)
                completion(true)
            } catch {
                completion(false)
            }
            }.resume()
    }
    
    
    func sendLocationData(coordinates : CLLocationCoordinate2D) {
        var userLocation = Location()
        userLocation.lat = Float(coordinates.latitude)
        userLocation.lng = Float(coordinates.longitude)
        
        let location = try? JSONEncoder().encode(userLocation)
        
        streamLocationSocket?.write(data: location!)
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("✅ Socket Connected: \(socket.isConnected)")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error as? WSError {
            print("❌ Websocket is disconnected: \(e.message)")
        } else if let e = error {
            print("❌ Websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("❌ Websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(text)
        if let locationDetails = text.data(using: .utf8, allowLossyConversion: false) {
            do {
                let locationList = try JSON(data: locationDetails)
                locations.removeAll()
                for item in locationList {
                    let locationJSON = item.1
                    var individual = AdminLocation()
                    individual.ac_no = locationJSON["ac_no"].stringValue
                    individual.is_connection_lost = locationJSON["is_connection_lost"].boolValue
                    individual.lat = locationJSON["lat"].floatValue
                    individual.lng = locationJSON["lng"].floatValue
                    individual.time = locationJSON["time"].doubleValue
                    individual.zone_no = locationJSON["zone_no"].string
                    
                    locations.append(individual)
                }
                
                
            } catch {
                print("❌ Did not recieve location")
            }
        }
        else {
            print("🔁 Retry")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("⬇️ Received data: \(data.count)")
    }
    
    func geoLocation(address: String, completion : @escaping(CLPlacemark?,Bool) -> ()) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil && placemarks?.count == 0 {
                
                completion(nil,false)
            }
            else {
                let placemark = placemarks?[0]
                completion(placemark!,true)
            }
        })
    }
    
    func setupSockets() {
        
        let userToken = UserDefaults.standard.value(forKey: "ElectionEye_token") as? String ?? ""
        guard let locationStreamURL = locationStreamURL else { return }
        guard let locationFetchURL = locationFetchURL else { return }
        
        var request = URLRequest(url: locationStreamURL)
        request.timeoutInterval = 5
        request.setValue("Bearer "+userToken, forHTTPHeaderField: "Authorization")
        streamLocationSocket = WebSocket(request: request)
        streamLocationSocket?.delegate = self
        streamLocationSocket?.connect()
        
        request = URLRequest(url: locationFetchURL)
        request.timeoutInterval = 5
        request.setValue("Bearer "+userToken, forHTTPHeaderField: "Authorization")
        fetchLocationSocket = WebSocket(request: request)
        fetchLocationSocket?.delegate = self
        fetchLocationSocket?.connect()
    }
    
}
