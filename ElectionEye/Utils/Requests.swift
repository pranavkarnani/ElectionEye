//
//  Requests.swift
//  ElectionEye
//
//  Created by Pranav Karnani on 06/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import Foundation
import FirebaseAuth
class Requests {
    
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
                print(error?.localizedDescription)
                completion(userDetails,false)
            }
            else {
                guard let data = data else { return }
                
                do {
                    userDetails = try JSONDecoder().decode(UserRoles.self, from: data)
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
                URLSession.shared.dataTask(with: fetchZonesURL, completionHandler: { (data, resposne, error) in
                    do {
                        guard let data = data else { return }
                        zones = try JSONDecoder().decode([Zones].self, from: data)
                        print(zones)
                        completion(zones,true)
                    } catch {
                        completion(zones,false)
                    }
                })
            }
        }.resume()
    }
}
