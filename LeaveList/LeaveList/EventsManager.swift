//
//  EventsManager.swift
//  LeaveList
//
//  Created by Dmitry on 11/8/16.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import Foundation
import SwiftLocation
import CoreLocation

class EventsManager {
    private var lastLocation: CLLocation?
    private var keys = [String]()
    
    init() {
        
    }
    
    func registerEventForListEntry(key: String) {
        LocationManager.shared.observeLocations(.Neighborhood, frequency: .OneShot, onSuccess: { location in
            // location contain your CLLocation object
            self.lastLocation = location
            
            let newRecord = ListEntryEvent()
            
            newRecord.text = ""
            newRecord.listEntryKey = key
            newRecord.longitude = location.coordinate.longitude
            newRecord.latitude = location.coordinate.latitude
            
            Model.save(newRecord)

        }) { error in
            // Something went wrong. error will tell you what
        }
    }
}