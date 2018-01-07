//
//  ScheduleOperation.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 07/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import Foundation

class ScheduleOperation: NetworkOperation {
    
    override init() {
        super.init()
    }
    
    override func main() {
        super.main()
        
        if self.operationType == .get {
            print("Getting Schedule...")
        }
        else if self.operationType == .post {
            print("Requesting Schedule...")
        }
        
        
        runRequest(endpoint: "schedule") { (status, data) in
            
            // 202 accepted if all ok
            // 400 if something goes wrong
            
            
            let decoder = JSONDecoder.init()
            decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
            
            switch status {
            case .accepted:
                print("Schedule Operation: Accepted")
                break
            case .ok:
                
                guard let d = data else {
                    self.completionHandler?(false, .dataUnavailable)
                    print("Error Schedule Operation: \n\tData unavailable")
                    return
                }
                
                guard let events = try? decoder.decode([Event].self, from: d) else {
                    self.completionHandler?(false, .dataUnavailable)
                    print("Error Schedule Operation: Unable to decode Events")
                    return
                }
                
                Database.shared.realm(completion: { (realm) in
                    if events.count > 0 {
                        try! realm.write {
                            realm.delete(realm.objects(Event.self).filter("calendar_id=\(events.first!.calendar_id)"))
                            realm.add(events)
                        }
                    }
                    
                    self.completionHandler?(true, nil)
                    
                    print("Schedule Received and Saved!")
                    API.shared.sendNotificationsFor(type: .events)
                })
                
                break
                
            default:
                self.completionHandler?(false, status)
                print("Error Schedule Operation: \n\tStatusCode: \(status)")
                break
                
            }
            
        }
        
    }
    
}
