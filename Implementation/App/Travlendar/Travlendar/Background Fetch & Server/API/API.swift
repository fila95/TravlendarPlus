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
    
    override public init() {
        super.init()
        
        let operation = LoginOperation()
        
        OperationQueue.main.addOperation(operation)
        OperationQueue.main.maxConcurrentOperationCount = 1
        
    }

}
