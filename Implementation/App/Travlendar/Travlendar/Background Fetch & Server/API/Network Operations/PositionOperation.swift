//
//  PositionOperation.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 07/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import Foundation

class PositionOperation: NetworkOperation {
    
    override init() {
        super.init()
        
        self.queuePriority = .low
    }
    
    override func main() {
        super.main()
        
        self.operationType = .patch
        
        runRequest(endpoint: "position") { (status, data) in
            
//            print(status)
            
            switch status {
                
            case .okNoContentNeeded:
                print("Position Operation: Succeeded")
                self.completionHandler?(true, nil)
                
            default:
                self.completionHandler?(false, status)
                print("Error Position Operation: \n\tStatusCode: \(status)")
                break
                
            }
            
        }
        
    }
    
}

