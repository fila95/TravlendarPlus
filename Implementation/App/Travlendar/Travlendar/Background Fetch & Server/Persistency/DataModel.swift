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

public class Settings: NSObject, Codable {
    
    @objc var eco_mode: Bool = false
    @objc var max_walking_distance: Float = 2000
    @objc var max_biking_distance: Float = 4000
    
    @objc var start_public_transportation: Date = Date()
    @objc var end_public_transportation: Date = Date()
    
    @objc var enjoy_enabled: Bool = false
    @objc var car2go_enabled: Bool = false
    @objc var uber_enabled: Bool = false
    @objc var mobike_enabled: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case eco_mode = "eco_mode"
        case max_walking_distance = "max_walking_distance"
        case max_biking_distance = "max_biking_distance"
        
        case start_public_transportation = "start_public_transportation"
        case end_public_transportation = "end_public_transportation"
        
        case enjoy_enabled = "enjoy_enabled"
        case car2go_enabled = "car2go_enabled"
        case uber_enabled = "uber_enabled"
        case mobike_enabled = "mobike_enabled"
    }
    
    func decode(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eco_mode = try container.decode(Bool.self, forKey: .eco_mode)
        self.max_walking_distance = try container.decode(Float.self, forKey: .max_walking_distance)
        self.max_biking_distance = try container.decode(Float.self, forKey: .max_biking_distance)
        
        self.start_public_transportation =  try container.decode(Date.self, forKey: .start_public_transportation)
        self.end_public_transportation = try container.decode(Date.self, forKey: .end_public_transportation)
        
        self.enjoy_enabled = try container.decode(Bool.self, forKey: .enjoy_enabled)
        self.car2go_enabled = try container.decode(Bool.self, forKey: .car2go_enabled)
        self.uber_enabled = try container.decode(Bool.self, forKey: .uber_enabled)
        self.mobike_enabled = try container.decode(Bool.self, forKey: .mobike_enabled)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.eco_mode, forKey: .eco_mode)
        try container.encode(self.max_walking_distance, forKey: .max_walking_distance)
        try container.encode(self.max_biking_distance, forKey: .max_biking_distance)
        
        try container.encode(self.start_public_transportation, forKey: .start_public_transportation)
        try container.encode(self.end_public_transportation, forKey: .end_public_transportation)
        
        try container.encode(self.enjoy_enabled, forKey: .enjoy_enabled)
        try container.encode(self.car2go_enabled, forKey: .car2go_enabled)
        try container.encode(self.uber_enabled, forKey: .uber_enabled)
        try container.encode(self.mobike_enabled, forKey: .mobike_enabled)
    }
    
    
}


class Travel: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var event_id: Int = 0
    
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
    
    
}

class Event: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var calendar_id = 0
    
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
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["title", "address"]
    }
    
}


public class Calendars: Object, Codable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name = ""
    @objc dynamic var color: String = ""
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    override public static func indexedProperties() -> [String] {
        return ["name"]
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case color = "color"
    }
    
    func decode(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.color = try container.decode(String.self, forKey: .color)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.color, forKey: .color)
        
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
