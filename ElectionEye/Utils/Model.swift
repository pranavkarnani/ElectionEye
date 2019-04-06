//
//  Model.swift
//  ElectionEye
//
//  Created by Pranav Karnani on 06/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import Foundation


struct UserRoles: Decodable {
    var ac_no : String?
    var zone_no : String?
    var role : Bool?
    var phone_no: String?
    var token : String?
}

struct Zones : Decodable {
    var ac_no : String?
    var zone_no : String?
    var sec_officer_names : String?
    var conduct_number : String?
    var poll_stn_count : Int?
    var location_count : Int?
    var poll_stn_no : String?
    var zone_name : String?
}

struct UserLogin : Codable {
    var phone_no : String?
}

let baseURL = "http://elections.vit.ac.in:3000/api/v1/"
let fetchZonesURL = URL(string: baseURL+"role")
let loginURL = URL(string: baseURL+"zones")
