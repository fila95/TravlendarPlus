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


/*
get {
    guard let s = UserDefaults.standard.string(forKey: "settings") else { return nil }
    guard let data = s.data(using: .utf8) else { return nil }
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(Formatter.time)
    return try! decoder.decode(Settings.self, from: data)
}
set (newValue) {
    guard let s = newValue else {
        return
    }
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(Formatter.time)
    
    UserDefaults.standard.set(String.init(data: try! encoder.encode(s), encoding: .utf8), forKey: "settings")
    UserDefaults.standard.synchronize()
}
*/
