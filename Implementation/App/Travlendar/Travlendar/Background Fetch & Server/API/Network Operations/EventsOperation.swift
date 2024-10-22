//
//  EventsOperation.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 02/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import Foundation
import RealmSwift

class EventsOperation: NetworkOperation {
    
    override init() {
        super.init()
    }
    
    override func main() {
        super.main()
        
        if self.operationType == .get {
            print("Getting Events for Calendar \(endpointAddition.split(separator: "/").dropLast().last ?? "not known")...")
        }
        else if self.operationType == .delete {
            print("Deleting Event number \(endpointAddition.split(separator: "/").last ?? "not known")...")
        }
        else {
            print("Pushing Event...")
        }
        
        
        runRequest(endpoint: "calendars") { (status, data) in
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
            
//            print(status)
            
            switch status {
            case .ok:
                
                guard let d = data else {
                    self.completionHandler?(false, .dataUnavailable)
                    print("Error Events Operation: \n\tData unavailable")
                    return
                }
                
                if self.operationType == .get {
                    
//                    print(String.init(data: d, encoding: .utf8) ?? "No str")
//                    do {
//                        try decoder.decode([Event].self, from: d)
//                    }
//                    catch {
//                        print(error)
//                    }

                    
                    guard let events = try? decoder.decode([Event].self, from: d) else {
                        self.completionHandler?(false, .dataUnavailable)
                        print("Error Events Operation: Unable to decode Events")
                        return
                    }
                    
                    Database.shared.realm(completion: { (realm) in
                        if events.count > 0 {
                            try! realm.write {
//                                realm.delete(realm.objects(Event.self).filter("calendar_id=\(events.first!.calendar_id)"))
//                                realm.add(events)
                                realm.add(events, update: true)
                            }
                        }
                        
                        self.completionHandler?(true, nil)
                        
                        print("Events Received and Saved!")
                        API.shared.sendNotificationsFor(type: .events)
                    })
                    
                    
                }
                else if self.operationType == .patch {
                    
                    guard let event = try? decoder.decode(Event.self, from: d) else {
                        self.completionHandler?(false, .dataUnavailable)
                        print("Error Events Operation: Unable to decode Events")
                        return
                    }
                    
                    Database.shared.realm(completion: { (realm) in
                        try! realm.write {
//                            realm.delete(realm.objects(Event.self).filter("id=\(event.id)"))
                            realm.add(event, update: true)
                        }
                        
                        self.completionHandler?(true, nil)
                        
                        print("Event Updated!")
                        API.shared.sendNotificationsFor(type: .events)
                    })
                }
                
                
                break
                
            case .created:
                guard let d = data else {
                    self.completionHandler?(false, .dataUnavailable)
                    print("Error Events Operation: \n\tData unavailable")
                    return
                }
                
                
//                print(String.init(data: d, encoding: .utf8) ?? "No str")
//                do {
//                    try decoder.decode(Event.self, from: d)
//                }
//                catch {
//                    print(error)
//                }
                
                guard let event = try? decoder.decode(Event.self, from: d) else {
                    self.completionHandler?(false, .dataUnavailable)
                    print("Error Events Operation: Unable to decode Event")
                    return
                }
                
                Database.shared.realm(completion: { (realm) in
                    try! realm.write {
//                        realm.delete(realm.objects(Event.self).filter("id=\(event.id)"))
                        realm.add(event, update: true)
                    }
                    
                    self.completionHandler?(true, nil)
                    
                    print("Event Added!")
                    API.shared.sendNotificationsFor(type: .events)
                })
                break
                
            case .okNoContentNeeded:
                
                Database.shared.realm(completion: { (realm) in
                    guard let id: Int = Int(self.endpointAddition.split(separator: "/").last!) else {
                        self.completionHandler?(false, .dataUnavailable)
                        return
                    }
                    
                    print(id)
                    
                    try! realm.write {
                        realm.delete(realm.objects(Event.self).filter("id=\(id)"))
                    }
                    
                    self.completionHandler?(true, nil)
                    
                    print("Event Deleted!")
                    API.shared.sendNotificationsFor(type: .events)
                })
                
                break
                
            default:
                self.completionHandler?(false, status)
                print("Error Events Operation: \n\tStatusCode: \(status)")
                break
                
            }
            
        }
        
    }
    
}
