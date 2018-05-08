//
//  Network.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 05/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation
import RealmSwift

public enum NStatusCode: Int {
    case ok = 200
    case created = 201
    case accepted = 202
    case okNoContentNeeded = 204
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notfound = 404
    case preconditionFailed = 412
    case internalServerError = 500
    case unavailable = 503
    case dataUnavailable = 1000
    
    public var description: String {
        switch self {
            case .ok: return "ok"
            case .created: return "created"
            case .okNoContentNeeded: return "okNoContentNeeded"
            case .accepted: return "accepted"
            case .badRequest: return "badRequest"
            case .unauthorized: return "unauthorized"
            case .forbidden: return "forbidden"
            case .notfound: return "not found"
            case .preconditionFailed: return "not reachable"
            case .internalServerError: return "internalServerError"
            case .unavailable: return "unavailable"
            case .dataUnavailable: return "data unavailable"
        }
    }
}

enum NOperationType: String {
    case get
    case post
    case delete
    case put
    case patch
}


class NetworkOperation: Operation {
    
    let session: URLSession!
    var task: URLSessionDataTask?
    
    var operationType: NOperationType = .get
    var httpBody: String = ""
    var endpointAddition: String = ""
    
    var completionHandler: ((_ complete: Bool, _ code: NStatusCode?) -> Void)?
    
    internal let semaphore = DispatchSemaphore(value: 0)
    
    deinit {
        semaphore.signal()
    }
    
    override init() {
        session = URLSession.shared
        
        super.init()
        
        self.queuePriority = .low
    }
    
    convenience init(operationType: NOperationType, endpointAddition: String? = nil, httpBody: String? = nil, completion: ((_ complete: Bool, _ code: NStatusCode?) -> Void)? = nil) {
        self.init()
        
        
        self.operationType = operationType
        self.endpointAddition = endpointAddition ?? ""
        self.httpBody = httpBody != nil ? httpBody! : ""
        self.completionHandler = completion
    }
    
    func runRequest(endpoint: String, completion: @escaping ((_ status: NStatusCode, _ data: Data?) -> Void)) {
        var request: URLRequest = URLRequest(url: URL.init(string: API.baseURL + endpoint + "/" + endpointAddition)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        
        request.httpMethod = self.operationType.rawValue.uppercased()
        request.httpBody = self.httpBody.data(using: .utf8)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let tk = Secret.shared.request_token {
            request.addValue("\(tk)", forHTTPHeaderField: "X-Access-Token")
        }
        
//        print(request.debugDescription)
//        print(request.description)
//        print(request.allHTTPHeaderFields)
//        print(self.httpBody)
        
        
        task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            
            if error != nil {
                print("Error \(endpoint.capitalized) Operation: \n\t Task Failed or Cancelled")
                self.completionHandler?(false, nil)
                return
            }
            
//            print(String.init(data: data!, encoding: .utf8))
            
            guard let sc = (response as? HTTPURLResponse)?.statusCode, let code = NStatusCode.init(rawValue: sc) else {
                self.completionHandler?(false, nil)
                print("Error \(endpoint.capitalized) Operation: \n\tResponse unavailable")
                
                return
            }
            
//            if code == .internalServerError {
//                print(String.init(data: data!, encoding: .utf8))
//                print(response)
//                print(error)
//            }
            DispatchQueue.global().sync {
                completion(code, data)
                self.semaphore.signal()
            }
        }
        self.task!.resume()
        self.semaphore.wait()
    }
    
    override func cancel() {
        super.cancel()
        self.task?.cancel()
        self.semaphore.signal()
        
    }
    

    
}


