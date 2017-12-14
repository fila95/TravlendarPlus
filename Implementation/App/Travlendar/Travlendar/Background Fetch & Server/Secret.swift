//
//  Secret.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 27/11/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import KeychainSwift

public class Secret: NSObject {
    
    static let shared: Secret = Secret()
    
    public var cloudId: String?
    public var appPreviouslyLaunched: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "launched")
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "launched")
            UserDefaults.standard.synchronize()
        }
    }
    
    public var request_token: String? {
        get {
            return UserDefaults.standard.string(forKey: "access_token")
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "access_token")
            UserDefaults.standard.synchronize()
        }
    }
    
    public var settings: Settings? {
        get {
            guard let s = UserDefaults.standard.string(forKey: "settings") else { return nil }
            guard let data = s.data(using: .utf8) else { return nil }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Formatter.time)
            return try! decoder.decode(Settings.self, from: data)
        }
        set (newValue) {
            guard let s = newValue, let encoded = Settings.representation(toRepresent: s) else {
                return
            }
            
            UserDefaults.standard.set(encoded, forKey: "settings")
            UserDefaults.standard.synchronize()
        }
    }
    
    private let CLOUD_KEY = "cloudID"
    private lazy var keychain: KeychainSwift = {
        let k = KeychainSwift()
        k.synchronizable = true
        return k
    }()
    
    
    
    override init() {
        super.init()
        cloudId = keychain.get(CLOUD_KEY)
        
        if cloudId == nil {
            // Generate new one
            print("Generating new cloud identifier...")
            
            cloudId = NSUUID().uuidString
            keychain.set(cloudId!, forKey: CLOUD_KEY)
            
        }
        else {
            print("Cloud identifier already stored!")
        }
        
        print("CloudId = \(cloudId ?? "null")")
    }
    
    
}


