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
                    guard let locationURL = locationURL else { return }
                    socket = WebSocket(url: locationURL)
                    userDetails = try JSONDecoder().decode(UserRoles.self, from: data)
                    self.firstConnection(user: userDetails)
                    print(userDetails)
                    completion(userDetails,true)
                } catch {
                    print(error.localizedDescription)
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
                    print(zones)
                    completion(zones,true)
                } catch {
                    print(error.localizedDescription)
                    completion(zones,false)
                }
            }
        }.resume()
    }
    
    func fetchConstituency(completion : @escaping([Constituency],Bool) -> ()) {
        guard let constituencyURL = constituencyURL else { return }
        var constituencies: [Constituency] = []
        URLSession.shared.dataTask(with: constituencyURL) { (data, response, error) in
            
            guard let data = data else {
                completion(constituencies,false)
                return
            }
            
            do {
                constituencies = try JSONDecoder().decode([Constituency].self, from: data)
                completion(constituencies, true)
            } catch {
                completion(constituencies,false)
            }
        }.resume()
    }
    
    func fetchPollStations(ac_no: String, completion : @escaping([PollStation],Bool)->()){
        guard let pollURL = pollURL else { return }
        var pollStations: [PollStation] = []
        URLSession.shared.dataTask(with: pollURL) { (data, response, error) in
            
            guard let data = data else {
                completion(pollStations,false)
                return
            }
            
            do {
                pollStations = try JSONDecoder().decode([PollStation].self, from: data)
                completion(pollStations, true)
            } catch {
                completion(pollStations,false)
            }
            }.resume()
    }
    
    
    func sendLocationData() {
        
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print(data)
    }
    
    func geoLocation(address: String, completion : @escaping(CLPlacemark?,Bool) -> ()) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                let placemark = CLPlacemark()
                completion(placemark,false)
            }
            if (placemarks?.count)! > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                completion(placemark!,true)
            }
        })
    }
    
    func firstConnection(user: UserRoles) {
        
        guard let locationURL = locationURL else { return }
        
        var request = URLRequest(url: locationURL)
        request.timeoutInterval = 5
        request.setValue("Bearer"+user.token!, forHTTPHeaderField: "Authorization")
        socket = WebSocket(request: request)
        
        socket?.connect()
    }
    
}
