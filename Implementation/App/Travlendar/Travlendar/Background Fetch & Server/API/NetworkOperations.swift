//
//  Network.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 05/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation

enum NStatusCode: Int {
    case ok = 200
    case created = 201
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case internalServerError = 500
    
    public var description: String {
        switch self {
        case .ok: return "ok"
        case .created: return "created"
        case .badRequest: return "badRequest"
        case .unauthorized: return "unauthorized"
        case .forbidden: return "forbidden"
        case .internalServerError: return "internalServerError"
        }
    }
}


class NetworkOperation: Operation {
    
    let session: URLSession!
    
    override init() {
        session = URLSession.shared
        
        
        super.init()
    }
    
}


class LoginOperation: NetworkOperation {
    
    override init() {
        super.init()
    }
    
    override func main() {
        super.main()
        
        var request: URLRequest = URLRequest(url: URL.init(string: API.baseURL + "login")!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        
        request.httpMethod = "POST"
        request.httpBody = ("user_token=\(Secret.shared.cloudId!)").data(using: .utf8)
//        request.addValue("", forHTTPHeaderField: "")
        
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                print("Error LoginOperation: \n\t\(error.debugDescription)")
                return
            }
            
            guard let sc = (response as? HTTPURLResponse)?.statusCode, let code = NStatusCode.init(rawValue: sc), let d = data else {
                print("Error LoginOperation: \n\tResponse or data unavailable")
                return
            }
            
            guard let dictionary = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as? [String : Any], let json = dictionary  else {
                print("Error LoginOperation: \n\tJSON Parse")
                return
            }
            
            switch code {
                case .ok:
                    let access_token: String = json["access_token"] as? String ?? ""
                    print("LoginOperation: \n\tAccess Token: \(access_token)")
                    API.shared.request_token = access_token
                break
                
            default:
                print("Error LoginOperation: \n\tStatusCode: \(code)")
                break
                
            }
            
            
        }
        task.resume()
        
    }
    
}
