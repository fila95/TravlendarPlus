//
//  DataModel+Codable.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 06/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation

protocol JSONRepresentable {
    static func representation<T: Codable>(toRepresent: T) -> String?
}


extension Settings: JSONRepresentable {
    
    static func representation<T>(toRepresent: T) -> String? where T : Codable {
        if toRepresent is Settings {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(Formatter.time)
            return String.init(data: try! encoder.encode(toRepresent), encoding: .utf8)
        }
        
        return nil
    }

}

extension Calendars: JSONRepresentable {
    
    static func representation<T>(toRepresent: T) -> String? where T : Codable {
        if toRepresent is Calendars {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(Formatter.iso8601)
            return String.init(data: try! encoder.encode(toRepresent), encoding: .utf8)
        }
        
        return nil
    }
    
}

extension Event: JSONRepresentable {
    
    static func representation<T>(toRepresent: T) -> String? where T : Codable {
        if toRepresent is Event {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(Formatter.iso8601)
            return String.init(data: try! encoder.encode(toRepresent), encoding: .utf8)
        }
        
        return nil
    }
    
}
