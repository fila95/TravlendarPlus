//
//  CalendarOperations.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 15/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation
import RealmSwift

class CalendarsOperation: NetworkOperation {
    
    override init() {
        super.init()
    }
    
    override func main() {
        super.main()
        
        if self.operationType == .get {
            print("Getting Calendars...")
        }
        else if self.operationType == .delete {
            print("Deleting Calendar...")
        }
        else {
            print("Pushing Calendar...")
        }
        
        
        runRequest(endpoint: "calendars") { (status, data) in
            
            let decoder = JSONDecoder.init()
            decoder.dateDecodingStrategy = .formatted(Formatter.time)
            
            switch status {
            case .ok:
                
                guard let d = data else {
                    self.completionHandler?(false, "Data Unavailable")
                    print("Error CalendarsOperation: \n\tData unavailable")
                    return
                }
                
                if self.operationType == .get {
                    
                    guard let calendars = try? decoder.decode([Calendars].self, from: d) else {
                        self.completionHandler?(false, "Decode Error")
                        print("Error Calendars Operation: Unable to decode Calendars")
                        return
                    }
                    
                    for c in calendars {
                        API.shared.getEventsFor(calendar: c)
                    }
                    
                    Database.shared.realm(completion: { (realm) in
                        try! realm.write {
                            realm.delete(realm.objects(Calendars.self))
                            realm.add(calendars)
                        }
                        
                        self.completionHandler?(true, nil)
                        
                        print("Calendars Received and Saved!")
                        API.shared.sendNotificationsFor(type: .calendars)
                    })
                    
                    
                }
                else if self.operationType == .patch {
                    
                    guard let calendar = try? decoder.decode(Calendars.self, from: d) else {
                        self.completionHandler?(false, "Decode Error")
                        print("Error Calendars Operation: Unable to decode Calendar")
                        return
                    }
                    
                    Database.shared.realm(completion: { (realm) in
                        try! realm.write {
                            realm.delete(realm.objects(Calendars.self).filter("id=\(calendar.id)"))
                            realm.add(calendar)
                        }
                        
                        self.completionHandler?(true, nil)
                        
                        print("Calendar Updated!")
                        API.shared.sendNotificationsFor(type: .calendars)
                    })
                }
                
                
                break
                
            case .created:
                guard let d = data else {
                    self.completionHandler?(false, "Data Unavailable")
                    print("Error CalendarsOperation: \n\tData unavailable")
                    return
                }
                
                guard let calendar = try? decoder.decode(Calendars.self, from: d) else {
                    self.completionHandler?(false, "Decode Error")
                    print("Error Calendars Operation: Unable to decode Calendar")
                    return
                }
                
                Database.shared.realm(completion: { (realm) in
                    try! realm.write {
                        realm.delete(realm.objects(Calendars.self).filter("id=\(calendar.id)"))
                        realm.add(calendar)
                    }
                    
                    self.completionHandler?(true, nil)
                    
                    print("Calendar Added!")
                    API.shared.sendNotificationsFor(type: .calendars)
                })
                break
                
            case .okNoContentNeeded:
                    
                    Database.shared.realm(completion: { (realm) in
                        guard let id: Int = Int(self.endpointAddition) else {
                            self.completionHandler?(false, "Error deleting...")
                            return
                        }
                        
                        try! realm.write {
                            realm.delete(realm.objects(Calendars.self).filter("id=\(id)"))
                        }
                        
                        self.completionHandler?(true, nil)
                        
                        print("Calendar Deleted!")
                        API.shared.sendNotificationsFor(type: .calendars)
                    })
                    
                break
                
            default:
                self.completionHandler?(false, "Error")
                print("Error Calendars Operation: \n\tStatusCode: \(status)")
                break
                
            }
            
        }
        
    }
    
}
