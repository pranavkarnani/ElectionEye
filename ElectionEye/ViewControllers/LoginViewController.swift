//
//  ViewController.swift
//  ElectionEye
//
//  Created by Pranav Karnani on 06/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var loginBttn: UIButton!
    var stage = 1
    var verificationID = ""
    var phone = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backView.layer.cornerRadius = 8
        backView.makeLoginCard()
        loginBttn.layer.cornerRadius = loginBttn.frame.height/2
        loginBttn.makeCard()
        phoneNumberField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: phoneNumberField.frame.height))
        phoneNumberField.leftViewMode = .always
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
                    self.loginBttn.alpha = 1.0
                    self.loginBttn.isEnabled = true
                    self.phoneNumberField.text = ""
                }
            }
            else {
                DispatchQueue.main.async {
                    self.showAlert(title: "OTP Verification Failed", message: "Please check your internet connection or try again later")
                    self.loginBttn.alpha = 1.0
                    self.loginBttn.isEnabled = true
                    self.phoneNumberField.text = ""
                }
            }
        }
    }
    
    func performVerification(otp : String) {
        Requests.shared.OTPVerification(otp: otp, verificationID: verificationID) { (verified) in
            if verified {
                Requests.shared.performLogin(phone: self.phone) {(details, verifiedUser) in
                    if verifiedUser {
                        UserDefaults.standard.set(details, forKey: "ElectionEye_user")
//                        self.getZones()
                        self.performSegue(withIdentifier: "loggedIn", sender: Any?.self)
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
        }
    }
    
    
    func getZones() {
        Requests.shared.getZones { (zoneData, fetchedZones) in
            if fetchedZones {
                //save this chut
            } else {
                print("Error fetching zones")
            }
        }
    }
    
}

