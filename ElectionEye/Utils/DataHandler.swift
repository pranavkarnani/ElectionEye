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
    
    func persistZones() {
        
    }
    
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
    
    func pollingStations() {
        
    }
    
    func persistStationDetails() {
        
    }
    
    func retrieveZones() {
        
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
            }
            
            if constituencies.count == results.count {
                completion(constituencies,true)
            }
            else {
                completion([],false)
            }
            
        } catch {
            print("error")
        }
    }
    
    func retrieveStationDetails() {
        
    }
    
    func retrievePollingStations() {
        
    }
}
