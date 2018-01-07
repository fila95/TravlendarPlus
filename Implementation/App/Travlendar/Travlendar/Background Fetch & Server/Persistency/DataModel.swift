//
//  DataModel.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 28/11/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation
import RealmSwift
import Realm


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
    
    @objc dynamic var id: Int = 0
    @objc dynamic var event_id: Int = 0
    
    @objc dynamic var route: Int = 0
    @objc dynamic var time: Int = 0
    @objc private dynamic var transport_mean_private: String = TransportMean.walking.rawValue
    var transport_mean: TransportMean {
        get { return TransportMean(rawValue: transport_mean_private)! }
        set { transport_mean_private = newValue.rawValue }
    }
    
    @objc dynamic var waypoints = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case event_id = "event_id"
        case route = "route"
        case time = "time"
        case transport_mean_private = "transport_mean"
        case waypoints = "waypoints"
    }
    
    
    public required init(from decoder: Decoder) throws {
        super.init()
        try self.decode(from: decoder)
    }
    
    required public init() {
        super.init()
    }
    
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    
    public func decode(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.event_id = try container.decode(Int.self, forKey: .event_id)
        
        self.route = try container.decode(Int.self, forKey: .route)
        self.time = try container.decode(Int.self, forKey: .time)
        
        self.transport_mean_private = try container.decode(String.self, forKey: .transport_mean_private)
        self.waypoints = try container.decode(String.self, forKey: .waypoints)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.event_id, forKey: .event_id)
        
        try container.encode(self.route, forKey: .route)
        try container.encode(self.time, forKey: .time)
        
        try container.encode(self.transport_mean_private, forKey: .transport_mean_private)
        try container.encode(self.waypoints, forKey: .waypoints)
    }
    
}

public class Event: Object, Codable {
    
    @objc dynamic var id = 0
    @objc dynamic var calendar_id = -1
    
    @objc dynamic var title = ""
    @objc dynamic var address = ""
    
    @objc dynamic var lat: Double = 1
    @objc dynamic var lng: Double = 1
    
    @objc dynamic var start_time: Date = Date()
    @objc dynamic var end_time: Date = Date().addingTimeInterval(3600)
    @objc dynamic var duration: Int = -1
    
    @objc dynamic var repetitions: String = "0000000"
    @objc dynamic var transports: String = "11111"
    
    @objc dynamic var suggested_start_time: Date = Date.init(timeIntervalSince1970: 0)
    @objc dynamic var suggested_end_time: Date = Date.init(timeIntervalSince1970: 0)
    
    @objc dynamic var reachable: Bool = true
    
    var travels = List<Travel>()
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    override public static func indexedProperties() -> [String] {
        return ["title", "address"]
    }
    
    public func relativeCalendar(completion: @escaping ((_ calendar: Calendars?) -> Void)) {
        Database.shared.realm { (realm) in
            completion(realm.objects(Calendars.self).filter("id=\(self.calendar_id)").first)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case calendar_id = "calendar_id"
        
        case title = "title"
        case address = "address"
        
        case lat = "lat"
        case lng = "lng"
        
        case start_time = "start_time"
        case end_time = "end_time"
        case duration = "duration"
        
        case repetitions = "repetitions"
        case transports = "transports"
        
        case suggested_start_time = "suggested_start_time"
        case suggested_end_time = "suggested_end_time"
        
        case reachable = "reachable"
        case travels = "travels"
    }
    
    
    public required init(from decoder: Decoder) throws {
        super.init()
        try self.decode(from: decoder)
    }
    
    required public init() {
        super.init()
    }
    
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    
    public func decode(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.calendar_id = try container.decode(Int.self, forKey: .calendar_id)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.address = try container.decode(String.self, forKey: .address)
        
        self.lat = try container.decodeIfPresent(Double.self, forKey: .lat) ?? 1
        self.lng = try container.decodeIfPresent(Double.self, forKey: .lng) ?? 1
        
        self.start_time = try container.decode(Date.self, forKey: .start_time)
        self.end_time = try container.decode(Date.self, forKey: .end_time)
        self.duration = try container.decodeIfPresent(Int.self, forKey: .duration) ?? -1
        
        self.repetitions = try container.decode(String.self, forKey: .repetitions)
        self.transports = try container.decode(String.self, forKey: .transports)
        
        self.suggested_start_time = (try container.decodeIfPresent(Date.self, forKey: .suggested_start_time)) ?? Date.init(timeIntervalSince1970: 0)
        self.suggested_end_time = (try container.decodeIfPresent(Date.self, forKey: .suggested_end_time)) ?? Date.init(timeIntervalSince1970: 0)
        
        self.reachable = try container.decodeIfPresent(Bool.self, forKey: .reachable) ?? true
        
        let travelsArray = try container.decodeIfPresent([Travel].self, forKey: .travels) ?? []
        let travelsList = List<Travel>()
        travelsList.append(objectsIn: travelsArray)
        self.travels = travelsList
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.calendar_id, forKey: .calendar_id)
        
        try container.encode(self.title, forKey: .title)
        try container.encode(self.address, forKey: .address)
        
        try container.encode(self.lat, forKey: .lat)
        try container.encode(self.lng, forKey: .lng)
        
        try container.encode(self.start_time, forKey: .start_time)
        try container.encode(self.end_time, forKey: .end_time)
        try container.encode(self.duration == -1 ? 0 : self.duration, forKey: .duration)
        
        try container.encode(self.repetitions, forKey: .repetitions)
        try container.encode(self.transports, forKey: .transports)
        
        try container.encode(self.suggested_start_time, forKey: .suggested_start_time)
        try container.encode(self.suggested_end_time, forKey: .suggested_end_time)
        
        try container.encode(self.reachable, forKey: .reachable)
    }
    
}


public class Calendars: Object, Codable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
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
