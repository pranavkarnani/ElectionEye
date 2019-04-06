//
//  ViewController.swift
//  ElectionEye
//
//  Created by Pranav Karnani on 06/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var loginBttn: UIButton!
    var stage = 1
    var verificationID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        Requests.shared.numberVerification(number: phoneNo) { (verification, otpSent) in
            if otpSent {
                self.verificationID = verification
                self.headerLabel.text = "Please enter the OTP you received"
                self.stage = 2
                self.loginBttn.alpha = 1.0
                self.loginBttn.isEnabled = true
            }
            else {
                self.showAlert(title: "OTP Verification Failed", message: "Please check your internet connection or try again later")
            }
        }
    }
    
    func performVerification(otp : String) {
        Requests.shared.OTPVerification(otp: otp, verificationID: verificationID) { (verified) in
            if verified {
                let phoneNo = "+91" + self.phoneNumberField.text!
                UserDefaults.standard.set(phoneNo, forKey: "ElectionEye_phoneNumber")
                print("DOne done done bitch")
            }
            else {
                self.showAlert(title: "Invalid", message: "Invalid OTP entered")
                self.loginBttn.isEnabled = false
                self.loginBttn.alpha = 0.3
            }
        }
        
    }
    
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let bttn = UIAlertAction(title: "Done", style: .cancel, handler: nil)
        alert.addAction(bttn)
        present(alert, animated: true, completion: nil)
    }
}

