//
//  Extensions.swift
//  ElectionEye
//
//  Created by Aritro Paul on 07/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    static let epink = UIColor(red: 252/255, green: 86/255, blue: 105/255, alpha: 1)
}

extension UIView{
    func makeCard(){
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.2
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func makeLoginCard(){
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 50
        self.layer.shadowOpacity = 0.15
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func iconView(text: String){
        self.frame = CGRect(x: 0, y: 0, width: 80, height: 20)
        self.backgroundColor = UIColor.epink
        self.layer.cornerRadius = self.frame.height/2
        let locationLabel = UILabel()
        locationLabel.textColor = UIColor.white
        locationLabel.text = text
        locationLabel.textAlignment = .center
        locationLabel.frame = CGRect(x: 5, y: 0, width: 70, height: 20)
        locationLabel.font = UIFont(name: "Lato-Bold", size: 10)
        self.addSubview(locationLabel)
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
