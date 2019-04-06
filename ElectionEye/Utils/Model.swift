//
//  Model.swift
//  ElectionEye
//
//  Created by Pranav Karnani on 06/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import Foundation


struct UserRoles: Decodable {
    
}

let baseURL = "http://elections.vit.ac.in:3000/api/v1/"
let fetchZonesURL = URL(string: baseURL+"role")
let loginURL = URL(string: baseURL+"zones")
