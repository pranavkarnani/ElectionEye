//
//  ViewController.swift
//  ElectionEye
//
//  Created by Pranav Karnani on 06/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation

class LoginViewController: UIViewController {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var loginBttn: UIButton!
    var z = 0
    var count = 0
    var stage = 1
    var verificationID = ""
    var phone = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataHandler.shared.clear { (clear) in
            if clear {
                self.fetchData()
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        backView.layer.cornerRadius = 8
        backView.makeLoginCard()
        loginBttn.layer.cornerRadius = loginBttn.frame.height/2
        loginBttn.makeCard()
        phoneNumberField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: phoneNumberField.frame.height))
        phoneNumberField.leftViewMode = .always
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func loginBttnTapped(_ sender: Any) {
        if self.stage == 1 && phoneNumberField.text?.count == 10 {
            performLogin(number: phoneNumberField.text!)
            loginBttn.isEnabled = false
            loginBttn.alpha = 0.3
        }
        else if stage == 2 && phoneNumberField.text?.count == 6 {
            phoneNumberField.clearsOnInsertion = true
            performVerification(otp: phoneNumberField.text!)
            loginBttn.isEnabled = false
            loginBttn.alpha = 0.3
        }
        else {
            var type = ""
            if stage == 1 {
                type = "phone number"
            }
            else if stage == 2 {
                type = "OTP"
            }
            self.showAlert(title: "Invalid", message: "Incorrect format check the "+type+" entered")
        }
    }
    
    func performLogin(number: String) {
        let phoneNo = "+91" + phoneNumberField.text!
        phone = phoneNumberField.text!
        Requests.shared.numberVerification(number: phoneNo) { (verification, otpSent) in
            if otpSent {
                DispatchQueue.main.async {
                    self.verificationID = verification
                    self.headerLabel.text = "Please enter the OTP you received"
                    self.stage = 2
                }
            }
            else {
                DispatchQueue.main.async {
                    self.showAlert(title: "OTP Verification Failed", message: "Please check your internet connection or try again later")
                }
            }
            self.loginBttn.alpha = 1.0
            self.loginBttn.isEnabled = true
            self.phoneNumberField.text = ""
        }
    }
    
    func performVerification(otp : String) {
        Requests.shared.OTPVerification(otp: otp, verificationID: verificationID) { (verified) in
            if verified {
                Requests.shared.performLogin(phone: self.phone) {(details, verifiedUser) in
                    if verifiedUser {
                        UserDefaults.standard.set(details.ac_no, forKey: "ElectionEye_ac_no")
                        UserDefaults.standard.set(details.phone_no, forKey: "ElectionEye_phone_no")
                        UserDefaults.standard.set(details.role, forKey: "ElectionEye_role")
                        UserDefaults.standard.set(details.token, forKey: "ElectionEye_token")
                        UserDefaults.standard.set(details.zone_no, forKey: "ElectionEye_zone_no")
                        Requests.shared.setupSockets()
                        self.transition()
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", message: "User does not exist")
                        }
                    }
                }
            }
            else {
                self.showAlert(title: "Invalid", message: "Invalid OTP entered")
            }
            
            self.loginBttn.alpha = 1.0
            self.loginBttn.isEnabled = true
            self.phoneNumberField.text = ""
        }
    }
    
    func fetchData() {
        Requests.shared.fetchConstituency { (fetched) in
            if fetched {
                self.transition()
            }
        }
        Requests.shared.fetchPollStations() { (fetched) in
            if fetched {
                self.transition()
            }
        }
        
        Requests.shared.fetchStation { (fetched) in
            if fetched {
                self.transition()
            }
        }
    }
    
    func transition() {
        count = count + 1
        if(count == 4) {
            DispatchQueue.main.async {
                UserDefaults.standard.set(4, forKey: "ElectionEye_login")
                self.performSegue(withIdentifier: "loggedIn", sender: Any?.self)
            }
        }
    }
    
    
    
}

