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

public enum APIContext {
    case success
    case error
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
    
    public func pushSettingsToServer(settings: Settings) {
        queue.addOperation(SettingsOperation(operationType: .patch, httpBody: Settings.representation(toRepresent: settings)))
    }
    
    
    // MARK: Subscriptions
    private var handlers = [(completion: ((context: APIContext) -> Void), type: APINotificationType)]()
    
    public func subscribe(type: APINotificationType, completion: @escaping (_ context: APIContext) -> Void) {
        DispatchQueue.init(label: "io.array").async {
            self.handlers += [(completion: completion, type: type)]
        }
    }
    
    public func sendNotificationsFor(type: APINotificationType, context: APIContext) {
        DispatchQueue.init(label: "notify").async {
            for handle in self.handlers {
                if handle.type == type {
                    handle.completion(context)
                }
            }
        }
        
    }
    
    

}
