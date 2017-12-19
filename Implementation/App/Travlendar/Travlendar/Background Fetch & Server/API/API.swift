//
//  API.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 27/11/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit


public enum APINotificationType {
    case settings
    case calendars
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
        
        queue.addOperation(SettingsOperation(operationType: .get))
        queue.addOperation(CalendarsOperation(operationType: .get))
    }
    
    public func pushSettingsToServer(settings: Settings, completion: ((_ complete: Bool, _ message: String?) -> Void)? = nil) {
        cancelOperationsOfType(t: SettingsOperation.classForCoder())
        queue.addOperation(SettingsOperation(operationType: .patch, httpBody: Settings.representation(toRepresent: settings), completion: completion))
    }
    
    public func deleteCalendarFromServer(calendar: Calendars, completion: ((_ complete: Bool, _ message: String?) -> Void)? = nil) {
        queue.addOperation(CalendarsOperation(operationType: .delete, httpBody: "\(calendar.id)", completion: completion))
    }
    
    
    public func pushNotificationTokenToServer(token: String) {
        cancelOperationsOfType(t: NotificationTokenOperation.classForCoder())
        queue.addOperation(NotificationTokenOperation(operationType: .put, httpBody: "{\"token\":\"\(token)\"}"))
    }
    
    
    // MARK: Utilities
    private func cancelOperationsOfType(t: AnyClass) {
        for op in queue.operations {
            if op.classForCoder == t {
                op.cancel()
            }
        }
    }
    
    
    // MARK: Subscriptions
    private var handlers = [(completion: (() -> Void), type: APINotificationType)]()
    
    public func subscribe(type: APINotificationType, completion: @escaping () -> Void) {
        
        DispatchQueue.init(label: "io.array.queue").async {
            objc_sync_enter(self.handlers)
            self.handlers += [(completion: completion, type: type)]
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
