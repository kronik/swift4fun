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
import DateTools

class EventsManager {
    private var lastLocation: CLLocation? {
        didSet {
            lastLocationTimestamp = NSDate()
        }
    }
    
    private var lastLocationTimestamp = NSDate.distantPast()
    private var lastLocationRequest: Request?
    
    init() { }
    
    func registerEventForListEntry(key: String) {
        if let location = lastLocation where lastLocationTimestamp.minutesAgo() <= 3 {
            createEventForListEntry(key, location: location)
        } else {
            lastLocationRequest = Location.getLocation(withAccuracy: .House, frequency: .OneShot, onSuccess: { location in
                // location contain your CLLocation object
                self.lastLocation = location
                self.createEventForListEntry(key, location: location)
                self.lastLocationRequest = nil
            }) { (location, error) in
                // Something went wrong. error will tell you what
            }
        }
    }
    
    func createEventForListEntry(key: String, location: CLLocation) {
        let newRecord = ListEntryEvent()
        
        newRecord.text = ""
        newRecord.listEntryKey = key
        newRecord.longitude = location.coordinate.longitude
        newRecord.latitude = location.coordinate.latitude
        
        Model.save(newRecord)
    }
}