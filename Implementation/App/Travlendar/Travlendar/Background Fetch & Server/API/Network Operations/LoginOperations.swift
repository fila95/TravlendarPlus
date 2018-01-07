//
//  LoginOperations.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 15/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation

class LoginOperation: NetworkOperation {
    
    override init() {
        super.init()
        
        self.queuePriority = .veryHigh
    }
    
    override func main() {
        super.main()
        
        self.httpBody = ("{\"user_token\":\"\(Secret.shared.cloudId!)\"}")
        self.operationType = .post
        
        runRequest(endpoint: "login") { (status, data) in
            
            switch status {
            case .ok:
                
                guard let d = data else {
                    self.completionHandler?(false, .dataUnavailable)
                    print("Error LoginOperation: \n\tData unavailable")
                    return
                }
                
                let json = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as! [String : Any]
                
                let access_token: String = json!["access_token"] as? String ?? ""
                print("LoginOperation: \n\tAccess Token: \(access_token)")
                Secret.shared.request_token = access_token
                self.completionHandler?(true, nil)
                
                break
                
            default:
                self.completionHandler?(false, status)
                print("Error LoginOperation: \n\tStatusCode: \(status)")
                break
                
            }
            
        }
        
    }
    
}
