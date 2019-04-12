//
//  DataHandler.swift
//  ElectionEye
//
//  Created by Pranav Karnani on 10/04/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataHandler {
    
    static let shared : DataHandler = DataHandler()
    
    func persistConstituencies(constituency : [Constituency]) {
        DispatchQueue.main.async {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            for item in constituency {
                let entity = NSEntityDescription.insertNewObject(forEntityName: "ConstituencyData", into: context)
                
                entity.setValue(item.ac_no, forKey: "ac_no")
                entity.setValue(item.booth_count, forKey: "booth_count")
                entity.setValue(item.location_count, forKey: "location_count")
                entity.setValue(item.name, forKey: "name")
            }
        }
    }
    
    func persistPollingStations(pollStations: [PollStation]) {
        DispatchQueue.main.async {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            for item in pollStations {
                let entity = NSEntityDescription.insertNewObject(forEntityName: "PollingStationData", into: context)
                
                entity.setValue(item.ac_no, forKey: "ac_no")
                entity.setValue(item.stn_no, forKey: "stn_no")
                entity.setValue(item.location_name, forKey: "location_name")
                entity.setValue(item.location_name_native, forKey: "location_name_native")
                entity.setValue(item.stn_address, forKey: "stn_address")
                entity.setValue(item.latitude, forKey: "latitude")
                entity.setValue(item.longitude, forKey: "longitude")
                entity.setValue(item.zone_no, forKey: "zone_no")
                entity.setValue(item.booths, forKey: "booths")
                entity.setValue(item.polling_location_incharge_number, forKey: "polling_location_incharge_number")
                
            }
        }
    }
    
    func persistStations(stations : [Station]) {
        DispatchQueue.main.async {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            for item in stations {
                let entity = NSEntityDescription.insertNewObject(forEntityName: "StationData", into: context)
                entity.setValue(item.ac_no, forKey: "ac_no")
                entity.setValue(item.booths, forKey: "booths")
                entity.setValue(item.conduct_number, forKey: "conduct_number")
                entity.setValue(item.is_vulnerable, forKey: "is_vulnerable")
                entity.setValue(item.latitude, forKey: "latitude")
                entity.setValue(item.location_name, forKey: "location_name")
                entity.setValue(item.location_name_native, forKey: "location_name_native")
                entity.setValue(item.longitude, forKey: "longitude")
                entity.setValue(item.name, forKey: "name")
                entity.setValue(item.officer_contact_number, forKey: "officer_contact_number")
                entity.setValue(item.officer_rank, forKey: "officer_rank")
                entity.setValue(item.police_officer_name, forKey: "police_officer_name")
                entity.setValue(item.police_station, forKey: "police_station")
                entity.setValue(item.polling_location_incharge_number, forKey: "polling_location_incharge_number")
                entity.setValue(item.sec_officer_names, forKey: "sec_officer_names")
                entity.setValue(item.stn_address, forKey: "stn_address")
                entity.setValue(item.stn_no, forKey: "stn_no")
                entity.setValue(item.zone_no, forKey: "zone_no")
            }
        }
        
    }
    
    func retrieveConstituencies(completion : @escaping([Constituency],Bool) -> ()) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ConstituencyData")
        
        do {
            let results = try context.fetch(request)
            var constituencies : [Constituency] = []
            for item in results as! [NSManagedObject] {
                var constituency = Constituency()
                constituency.ac_no = item.value(forKey: "ac_no") as? String ?? ""
                constituency.booth_count = item.value(forKey: "booth_count") as? Int ?? -99
                constituency.location_count = item.value(forKey: "location_count") as? Int ?? -99
                constituency.name = item.value(forKey: "name") as? String ?? ""
                
                constituencies.append(constituency)
                
                if constituencies.count == results.count {
                    completion(constituencies,true)
                }
            }
            
        } catch {
            completion([],false)
            print("error")
        }
    }
    
    func retrievePollingStations(ac_no: String, completion : @escaping([PollStation],Bool) -> ()) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PollingStationData")
        
        do {
            request.predicate = NSPredicate(format: "ac_no = %@", argumentArray: [ac_no])
            
            let results = try context.fetch(request)
            var pollstations : [PollStation] = []
            for item in results as! [NSManagedObject] {
                var pollstation = PollStation()
                pollstation.stn_no =  item.value(forKey: "stn_no") as? Int ?? 0
                pollstation.location_name =  item.value(forKey: "location_name") as? String ?? ""
                pollstation.location_name_native =  item.value(forKey: "location_name_native") as? String ?? ""
                pollstation.stn_address =  item.value(forKey: "stn_address") as? String ?? ""
                pollstation.latitude =  item.value(forKey: "latitude") as? Double ?? 0.0
                pollstation.longitude =  item.value(forKey: "longitude") as? Double ?? 0.0
                pollstation.zone_no =  item.value(forKey: "zone_no") as? String ?? ""
                pollstation.booths =  item.value(forKey: "booths") as? String ?? ""
                pollstation.polling_location_incharge_number =  item.value(forKey: "polling_location_incharge_number") as? String ?? ""
                pollstation.ac_no =  item.value(forKey: "ac_no") as? String ?? ""
                pollstations.append(pollstation)
                
                if pollstations.count == results.count {
                    completion(pollstations,true)
                }
            }
        } catch {
            completion([],false)
            print("error")
        }
    }

    func  retrieveStations(ac_no: String, stn_no:Int, completion : @escaping([Station],Bool) -> ()) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "StationData")
        
        do {
            let constPredicate = NSPredicate(format: "ac_no = %@", argumentArray: [ac_no])
            let stationPredicate = NSPredicate(format: "stn_no == \(stn_no)")
            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [constPredicate,stationPredicate])
            request.predicate = predicate
            
            let results = try context.fetch(request)
            
            var stations : [Station] = []
            for item in results as! [NSManagedObject] {
                var station = Station()
                station.ac_no = item.value(forKey: "ac_no") as? String ?? ""
                station.booths = item.value(forKey: "booths") as? String ?? ""
                station.conduct_number = item.value(forKey: "conduct_number") as? String ?? ""
                station.is_vulnerable = item.value(forKey: "is_vulnerable") as? Bool ?? false
                station.latitude = item.value(forKey: "latitude") as? Float ?? 12.9165
                station.location_name = item.value(forKey: "location_name") as? String ?? ""
                station.location_name_native = item.value(forKey: "location_name_native") as? String ?? ""
                station.longitude = item.value(forKey: "longitude") as? Float ?? 79.1325
                station.name = item.value(forKey: "name") as? String ?? ""
                station.officer_contact_number = item.value(forKey: "officer_contact_number") as? String ?? ""
                station.officer_rank = item.value(forKey: "officer_rank") as? String ?? ""
                station.police_officer_name = item.value(forKey: "police_officer_name") as? String ?? ""
                station.police_station = item.value(forKey: "police_station") as? String ?? ""
                station.polling_location_incharge_number = item.value(forKey: "polling_location_incharge_number") as? String ?? ""
                station.sec_officer_names = item.value(forKey: "sec_officer_names") as? String ?? ""
                station.stn_address = item.value(forKey: "stn_address") as? String ?? ""
                station.stn_no = item.value(forKey: "stn_no") as? Int16 ?? 0
                station.zone_no = item.value(forKey: "zone_no") as? String ?? ""
                
                stations.append(station)
                if stations.count == results.count {
                    print(stations)
                    completion(stations,true)
                }
            }

        } catch {
            completion([],false)
            print("error")
        }
    }
}
