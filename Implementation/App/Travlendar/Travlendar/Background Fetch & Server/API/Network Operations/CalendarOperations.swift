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
            
            switch status {
            case .ok:
                
                guard let d = data else {
                    self.completionHandler?(false, "Data Unavailable")
                    print("Error CalendarsOperation: \n\tData unavailable")
                    return
                }
                
                let decoder = JSONDecoder.init()
                decoder.dateDecodingStrategy = .formatted(Formatter.time)
                guard let calendars = try? decoder.decode([Calendars].self, from: d) else {
                    self.completionHandler?(false, "Decode Error")
                    print("Error Calendars Operation: Unable to decode Calendars")
                    return
                }
                
                
                if self.operationType == .get {
                    
                    DispatchQueue(label: "background").async {
                        autoreleasepool {
                            let realm = try! Realm()
                            
                            try! realm.write {
                                realm.delete(realm.objects(Calendars.self))
                                realm.add(calendars)
                            }
                            
                            self.completionHandler?(true, nil)
                        }
                    }
                    
                    print("Calendars Received and Saved!")
                    API.shared.sendNotificationsFor(type: .calendars)
                }
                else if self.operationType == .patch {
                    
                    DispatchQueue(label: "background").async {
                        autoreleasepool {
                            let realm = try! Realm()
                            
                            try! realm.write {
                                realm.delete(realm.objects(Calendars.self).filter("id=\(calendars.first!.id)"))
                                realm.add(calendars)
                            }
                            
                            self.completionHandler?(true, nil)
                        }
                    }
                    
                    print("Calendar Updated!")
                    API.shared.sendNotificationsFor(type: .calendars)
                }
                else {
                    print("Calendar Pushed!")
                    
                    DispatchQueue(label: "background").async {
                        autoreleasepool {
                            let realm = try! Realm()
                            
                            try! realm.write {
                                realm.delete(realm.objects(Calendars.self).filter("id=\(calendars.first!.id)"))
                                realm.add(calendars)
                            }
                            
                            self.completionHandler?(true, nil)
                        }
                    }
                    
                }
                
                
                break
                
            case .okNoContentNeeded:
                    print("Calendar Deleted!")
                    
                    DispatchQueue(label: "background").async {
                        autoreleasepool {
                            let realm = try! Realm()
                            
                            guard let id: Int = Int(self.httpBody) else {
                                self.completionHandler?(false, "Error deleting...")
                                return
                            }
                            
                            try! realm.write {
                                realm.delete(realm.objects(Calendars.self).filter("id=\(id)"))
                            }
                            
                            self.completionHandler?(true, nil)
                        }
                    }
                    
                    
                    
                break
                
            default:
                self.completionHandler?(false, "Error")
                print("Error Calendars Operation: \n\tStatusCode: \(status)")
                break
                
            }
            
        }
        
    }
    
}
