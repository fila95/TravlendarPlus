//
//  DataModel.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 28/11/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation
import RealmSwift


// Define your models like regular Swift classes

// MARK: Enums

enum TransportMean: String {
    
    case walking
    case biking
    case public_transport
    case sharing
    case car
    
}

// MARK: Classes

class Settings: Object {
    
    @objc dynamic var eco_mode: Bool = false
    @objc dynamic var max_walking_distance = 2000
    @objc dynamic var max_biking_distance = 4000
    
    @objc dynamic var start_public_transportation = 0
    @objc dynamic var end_public_transportation = 0
    
    @objc dynamic var enjoy_enabled: Bool = false
    @objc dynamic var car2go_enabled: Bool = false
    @objc dynamic var uber_enabled: Bool = false
    @objc dynamic var mobike_enabled: Bool = false
    
}


class Travel: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var route = 0
    @objc dynamic var time = 0
    @objc private dynamic var transport_mean_private = TransportMean.walking.rawValue
    var transport_mean: TransportMean {
        get { return TransportMean(rawValue: transport_mean_private)! }
        set { transport_mean_private = newValue.rawValue }
    }
    
    @objc dynamic var waypoints = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    let event = LinkingObjects(fromType: Event.self, property: "travels")
    
}

class Event: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var address = ""
    
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    
    @objc dynamic var start_time: Int = 0
    @objc dynamic var end_time: Int = 0
    @objc dynamic var duration: Int = 0
    
    @objc dynamic var repetitions: Int8 = 0b00000000
    @objc dynamic var transports: Int8 = 0b00001111
    
    @objc dynamic var suggested_start_time: Int = 0
    @objc dynamic var suggested_end_time: Int = 0
    
    let travels = List<Travel>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["title", "address"]
    }
    
    
    let calendar = LinkingObjects(fromType: Calendar.self, property: "events")
    
}


class Calendar: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name = ""
    @objc dynamic var color: Int = 0
    
    let events = List<Event>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
    
}


class Company: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var company_name = ""
    @objc dynamic var phone_number = ""
    @objc dynamic var content = ""
    @objc dynamic var url_redirect = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
