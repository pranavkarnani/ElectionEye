//
//  Model.swift
//  ElectionEye
//
//  Created by Pranav Karnani on 06/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import Foundation
import Starscream

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

struct Constituency: Decodable {
    var name: String?
    var ac_no: String?
    var location_count: Int?
    var booth_count: Int?
}

struct PollStation: Decodable {
    var stn_no: Int?
    var location_name: String?
    var location_name_native: String?
    var stn_address: String?
    var latitude: Double?
    var longitude: Double?
    var zone_no: String?
    var booths: String?
    var polling_location_incharge_number: String?
    var ac_no: String?
}

struct Station: Decodable {
    var ac_no : String?
    var stn_no: Int?
    var location_name: String?
    var location_name_native: String?
    var stn_address: String?
    var latitude: Float?
    var longitude: Float?
    var zone_no: String?
    var sec_officer_names: String?
    var conduct_number: String?
    var name: String?
    var booths: String?
    var is_vulnerable: Bool?
    var vulnerable_booth_detail: [BoothDetails]?
}

struct BoothDetails: Decodable {
    var stn_name: String?
    var vul_habitats: String?
    var vul_types: String?
    var undersirable_elements: String?
    var stn_no: Int?
    var polling_location_no: Int?
}

let baseURL = "http://elections.vit.ac.in:3000/api/v1/"
let locationStreamURL = URL(string: "ws://election.vit.ac.in:3000/stream/locations/")
let locationFetchURL = URL(string: "ws://election.vit.ac.in:3000/stream/")
let fetchZonesURL = URL(string: baseURL+"zones")
let loginURL = URL(string: baseURL+"role")
let pollURL = URL(string: baseURL+"poll")
let constituencyURL = URL(string:  baseURL + "constituencies")
var streamLocationSocket : WebSocket?
var fetchLocationSocket : WebSocket?
let stationURL = URL(string: baseURL + "stations")
var socket : WebSocket?
