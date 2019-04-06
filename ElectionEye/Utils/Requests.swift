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
    
    func performLogin() {
        
        guard let loginURL = loginURL else { return }
        
        URLSession.shared.dataTask(with: loginURL) { (data, response, error) in
            if error != nil {
                
            }
            else {
                
            }
        }.resume()
    }
    
    func getZones() {
        
        guard let fetchZonesURL = fetchZonesURL else { return }
        
        URLSession.shared.dataTask(with: fetchZonesURL) { (data, response, error) in
            if error != nil {
                
            }
            else {
                
            }
        }.resume()
    }
}
