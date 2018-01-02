//
//  Network.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 05/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation
import RealmSwift

enum NStatusCode: Int {
    case ok = 200
    case created = 201
    case okNoContentNeeded = 204
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notfound = 404
    case internalServerError = 500
    
    public var description: String {
        switch self {
        case .ok: return "ok"
        case .created: return "created"
        case .okNoContentNeeded: return "okNoContentNeeded"
        case .badRequest: return "badRequest"
        case .unauthorized: return "unauthorized"
        case .forbidden: return "forbidden"
        case .notfound: return "not found"
        case .internalServerError: return "internalServerError"
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
    
    var completionHandler: ((_ complete: Bool, _ message: String?) -> Void)?
    
    override init() {
        session = URLSession.shared
        
        super.init()
        
        self.queuePriority = .low
    }
    
    convenience init(operationType: NOperationType, endpointAddition: String? = nil, httpBody: String? = nil, completion: ((_ complete: Bool, _ message: String?) -> Void)? = nil) {
        self.init()
        
        
        self.operationType = operationType
        self.endpointAddition = endpointAddition ?? ""
        self.httpBody = httpBody != nil ? httpBody! : ""
        self.completionHandler = completion
    }
    
    func runRequest(endpoint: String, completion: @escaping ((_ status: NStatusCode, _ data: Data?) -> Void)) {
        var request: URLRequest = URLRequest(url: URL.init(string: API.baseURL + endpoint + "/" + endpointAddition)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        
//        print(request)
        
        request.httpMethod = self.operationType.rawValue.uppercased()
        request.httpBody = self.httpBody.data(using: .utf8)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let tk = Secret.shared.request_token {
            request.addValue("\(tk)", forHTTPHeaderField: "X-Access-Token")
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                print("Error \(endpoint.capitalized) Operation: \n\t\(error.debugDescription)")
                self.completionHandler?(false, "Error")
                return
            }
            
//            print(String.init(data: data!, encoding: .utf8))
            
            guard let sc = (response as? HTTPURLResponse)?.statusCode, let code = NStatusCode.init(rawValue: sc) else {
                self.completionHandler?(false, "Response Unavailable")
                print("Error \(endpoint.capitalized) Operation: \n\tResponse unavailable")
                return
            }
            
            completion(code, data)
            semaphore.signal()
        }
        task!.resume()
        semaphore.wait()
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
    
}


