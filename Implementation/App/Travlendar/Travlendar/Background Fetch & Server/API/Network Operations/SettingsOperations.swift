//
//  SettingsOperations.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 15/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation

class SettingsOperation: NetworkOperation {
    
    override init() {
        super.init()
    }
    
    override func main() {
        super.main()
        
        if self.operationType == .get {
            print("Getting Settings...")
        }
        else {
            print("Pushing Settings...")
        }
        
        runRequest(endpoint: "settings") { (status, data) in
            
            switch status {
            case .ok:
                
                guard let d = data else {
                    self.completionHandler?(false, .dataUnavailable)
                    print("Error Settings Operation: \n\tData unavailable")
                    return
                }
                
                
                let decoder = JSONDecoder.init()
                decoder.dateDecodingStrategy = .formatted(Formatter.time)
                
                guard let settings = try? decoder.decode(Settings.self, from: d) else {
                    print("Error Settings Operation: Unable to decode Settings")
                    self.completionHandler?(false, .dataUnavailable)
                    return
                }
                Secret.shared.settings = settings
                
                if self.operationType == .get {
                    print("Settings Received and Saved!")
                }
                else {
                    print("Settings Pushed!")
                }
                
                self.completionHandler?(true, nil)
                API.shared.sendNotificationsFor(type: .settings)
                
                break
                
            default:
                self.completionHandler?(false, status)
                print("Error Settings Operation: \n\tStatusCode: \(status)")
                break
                
            }
            
        }
        
    }
    
}
