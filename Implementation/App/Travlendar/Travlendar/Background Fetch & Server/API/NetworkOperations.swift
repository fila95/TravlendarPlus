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

enum NOperationType: String {
    case get
    case post
    case patch
}


class NetworkOperation: Operation {
    
    let session: URLSession!
    
    var operationType: NOperationType = .get
    var httpBody: String = ""
    
    override init() {
        session = URLSession.shared
        
        super.init()
    }
    
    convenience init(operationType: NOperationType, httpBody: String? = nil) {
        self.init()
        
        self.operationType = operationType
        self.httpBody = httpBody != nil ? httpBody! : ""
    }
    
    func runRequest(endpoint: String, completion: @escaping ((_ status: NStatusCode, _ result: [String : Any]?, _ data: Data?) -> Void)) {
        
        var request: URLRequest = URLRequest(url: URL.init(string: API.baseURL + endpoint)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        
        request.httpMethod = self.operationType.rawValue.uppercased()
        request.httpBody = self.httpBody.data(using: .utf8)
        
        if let tk = Secret.shared.request_token {
            request.addValue("\(tk)", forHTTPHeaderField: "X-Access-Token")
        }
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                print("Error \(endpoint.capitalized) Operation: \n\t\(error.debugDescription)")
                return
            }
            
            guard let sc = (response as? HTTPURLResponse)?.statusCode, let code = NStatusCode.init(rawValue: sc), let d = data else {
                print("Error \(endpoint.capitalized) Operation: \n\tResponse or data unavailable")
                return
            }
            
            guard let dictionary = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as? [String : Any], let json = dictionary  else {
                print("Error \(endpoint.capitalized) Operation: \n\tJSON Parse")
                return
            }
            
            completion(code, json, data)
        }
        task.resume()
    }
    
}


class LoginOperation: NetworkOperation {
    
    override init() {
        super.init()
    }
    
    override func main() {
        super.main()
        
        self.httpBody = ("user_token=\(Secret.shared.cloudId!)")
        self.operationType = .post
        
        runRequest(endpoint: "login") { (status, json, data) in
            
            switch status {
            case .ok:
                let access_token: String = json!["access_token"] as? String ?? ""
                print("LoginOperation: \n\tAccess Token: \(access_token)")
                Secret.shared.request_token = access_token
                break
                
            default:
                print("Error LoginOperation: \n\tStatusCode: \(status)")
                break
                
            }
            
        }
        
    }
    
}

class SettingsOperation: NetworkOperation {
    
    override init() {
        super.init()
    }
    
    override func main() {
        super.main()
        
        runRequest(endpoint: "settings") { (status, json, data) in
            
            switch status {
            case .ok:
//                print(json!.debugDescription)
                let decoder = JSONDecoder.init()
                decoder.dateDecodingStrategy = .formatted(Formatter.time)
                
                guard let settings = try? decoder.decode(Settings.self, from: data!) else {
                    print("Error Settings Operation: Unable to decode Settings")
                    return
                }
                Secret.shared.settings = settings
                print("Settings Received and Saved")
                
                break
                
            default:
                print("Error Settings Operation: \n\tStatusCode: \(status)")
                break
                
            }
            
        }
        
    }
    
}

