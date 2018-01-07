//
//  API.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 27/11/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import CoreLocation


public enum APINotificationType {
    case settings
    case calendars
    case events
}

public class API: NSObject {
    
    public static let shared: API = API()
    public static let baseURL: String = "https://polimi-travlendarplus.herokuapp.com/api/v1/"
//    public static let baseURL: String = "http://localhost:8080/api/v1/"
    
    private let queue: OperationQueue!
    
    override public init() {
        queue = OperationQueue()
//        queue.underlyingQueue = DispatchQueue(label: "background_networking", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: DispatchQueue.main)
        super.init()
        
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        
        
        if Secret.shared.request_token == nil {
            print("Token Not Received: \n\tAsk Server...")
            queue.addOperation(LoginOperation())
        }
        else {
            print("Already have token: \n\t\(Secret.shared.request_token!)")
        }
        
        
        Location.shared.requestAuthorizationIfNeeded { (authorized) in
            self.pushUserPosition()
        }
        Location.shared.subscribe { (coordinateUpdate) in
            self.cancelOperationsOfType(t: PositionOperation.classForCoder())
            self.queue.addOperation(PositionOperation(operationType: .patch, endpointAddition: nil, httpBody: "{\"lat\":\"\(coordinateUpdate.latitude)\", \"lng\":\"\(coordinateUpdate.longitude)\"}"))
            self.triggerSchedule()
        }
        
        triggerSync()
    }
    
    public func triggerSync() {
        
        print("Sync Triggered")
        queue.addOperation(SettingsOperation(operationType: .get))
        queue.addOperation(CalendarsOperation(operationType: .get))
        self.pushUserPosition()
        
    }
    
    // MARK: Settings
    
    public func pushSettingsToServer(settings: Settings, completion: ((_ complete: Bool, _ code: NStatusCode?) -> Void)? = nil) {
        cancelOperationsOfType(t: SettingsOperation.classForCoder())
        queue.addOperation(SettingsOperation(operationType: .patch, httpBody: Settings.representation(toRepresent: settings), completion: completion))
    }
    
    // MARK: Calendars
    
    public func deleteCalendarFromServer(calendar: Calendars, completion: ((_ complete: Bool, _ code: NStatusCode?) -> Void)? = nil) {
        queue.addOperation(CalendarsOperation(operationType: .delete, endpointAddition: "\(calendar.id)", completion: completion))
    }
    
    public func updateCalendar(calendar: Calendars, completion: ((_ complete: Bool, _ code: NStatusCode?) -> Void)? = nil) {
        queue.addOperation(CalendarsOperation(operationType: .patch, endpointAddition: "\(calendar.id)", httpBody: Calendars.representation(toRepresent: calendar), completion: completion))
    }
    
    public func addCalendar(calendar: Calendars, completion: ((_ complete: Bool, _ code: NStatusCode?) -> Void)? = nil) {
        queue.addOperation(CalendarsOperation(operationType: .put, httpBody: Calendars.representation(toRepresent: calendar), completion: completion))
    }
    
    // MARK: Events
    
    public func getEventsFor(calendar: Calendars, completion: ((_ complete: Bool, _ code: NStatusCode?) -> Void)? = nil) {
        queue.addOperation(EventsOperation(operationType: .get, endpointAddition: "\(calendar.id)/events/", completion: completion))
    }
    
    public func deleteEventFromServer(event: Event, completion: ((_ complete: Bool, _ code: NStatusCode?) -> Void)? = nil) {
        queue.addOperation(EventsOperation(operationType: .delete, endpointAddition: "\(event.calendar_id)/events/\(event.id)", completion: completion))
    }
    
    public func updateEvent(event: Event, completion: ((_ complete: Bool, _ code: NStatusCode?) -> Void)? = nil) {
        queue.addOperation(EventsOperation(operationType: .patch, endpointAddition: "\(event.calendar_id)/events/\(event.id)", httpBody: Event.representation(toRepresent: event), completion: completion))
    }
    
    public func addEvent(event: Event, completion: ((_ complete: Bool, _ code: NStatusCode?) -> Void)? = nil) {
        queue.addOperation(EventsOperation(operationType: .put, endpointAddition: "\(event.calendar_id)/events/", httpBody: Event.representation(toRepresent: event), completion: completion))
        self.triggerSchedule()
    }
    
    public func triggerSchedule(completion: ((_ complete: Bool, _ code: NStatusCode?) -> Void)? = nil) {
        cancelOperationsOfType(t: ScheduleOperation.classForCoder())
        queue.addOperation(ScheduleOperation(operationType: .post, endpointAddition: "", httpBody: nil, completion: completion))
    }
    
    public func getSchedule(completion: ((_ complete: Bool, _ code: NStatusCode?) -> Void)? = nil) {
        cancelOperationsOfType(t: ScheduleOperation.classForCoder())
        queue.addOperation(ScheduleOperation(operationType: .get, endpointAddition: "", httpBody: nil, completion: completion))
    }
    
    public func pushUserPosition() {
        Location.shared.requestLocationUpdate()
    }
    
    // MARK: Notification
    
    public func pushNotificationTokenToServer(token: String) {
        cancelOperationsOfType(t: NotificationTokenOperation.classForCoder())
        queue.addOperation(NotificationTokenOperation(operationType: .put, httpBody: "{\"token\":\"\(token)\"}"))
    }
    
    
    // MARK: Utilities
    private func cancelOperationsOfType(t: AnyClass) {
        
        for (_, num) in self.queue.operations.enumerated().reversed() {
            if num.classForCoder == t {
                num.cancel()
            }
            
        }
    }
    
    
    // MARK: Subscriptions
    private var handlers = [(completion: (() -> Void), type: APINotificationType)]()
    
    public func subscribe(type: APINotificationType, completion: @escaping () -> Void) {
        
        DispatchQueue.init(label: "io.array.queue").async {
            objc_sync_enter(self.handlers)
            self.handlers.append((completion: completion, type: type))
            objc_sync_exit(self.handlers)
        }
        
    }
    
    public func addHandlers(handlers: [(completion: (() -> Void), type: APINotificationType)]) {
        DispatchQueue.init(label: "io.array.queue").async {
            objc_sync_enter(self.handlers)
            self.handlers.append(contentsOf: handlers)
            objc_sync_exit(self.handlers)
        }
    }
    
    public func sendNotificationsFor(type: APINotificationType) {
        DispatchQueue.init(label: "io.array.queue").async {
            objc_sync_enter(self.handlers)
            for handle in self.handlers {
                if handle.type == type {
                    handle.completion()
                }
            }
            objc_sync_exit(self.handlers)
        }
        
    }
    
    

}
