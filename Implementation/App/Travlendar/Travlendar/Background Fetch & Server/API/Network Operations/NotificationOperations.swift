//
//  NotificationOperations.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 15/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation

class NotificationTokenOperation: NetworkOperation {
    
    override init() {
        super.init()
        
        self.queuePriority = .veryHigh
    }
    
    override func main() {
        super.main()
        
        self.operationType = .put
        
        runRequest(endpoint: "pushNotificationToken") { (status, data) in
            
            switch status {
            case .okNoContentNeeded:
                print("NotificationTokenOperation: Received Ok")
                self.completionHandler?(true, nil)
                break
                
            default:
                print("Error NotificationTokenOperation: \n\tStatusCode: \(status)")
                self.completionHandler?(false, status)
                break
                
            }
            
        }
        
    }
    
}
