//
//  API.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 27/11/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

public class API: NSObject {
    
    public static let shared: API = API()
    
    public static let baseURL: String = "https://polimi-travlendarplus.herokuapp.com/api/v1/"
    
    public var request_token: String? {
        get {
            return UserDefaults.standard.string(forKey: "access_token")
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "access_token")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    
    private let queue: OperationQueue!
    
    override public init() {
        queue = OperationQueue()
        super.init()
        
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        
        if self.request_token == nil {
            print("Token Not Received: \n\tAsk Server...")
            
            let operation = LoginOperation()
            queue.addOperation(operation)
        }
        else {
            print("Already have token: \n\t\(request_token!)")
        }
        
        
    }

}
