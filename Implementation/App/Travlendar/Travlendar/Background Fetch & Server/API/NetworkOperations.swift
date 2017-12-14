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
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notfound = 404
    case internalServerError = 500
    
    public var description: String {
        switch self {
        case .ok: return "ok"
        case .created: return "created"
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
    case patch
}


class NetworkOperation: Operation {
    
    let session: URLSession!
    var task: URLSessionDataTask?
    
    var operationType: NOperationType = .get
    var httpBody: String = ""
    
    override init() {
        session = URLSession.shared
        
        super.init()
        
        self.queuePriority = .low
    }
    
    convenience init(operationType: NOperationType, httpBody: String? = nil) {
        self.init()
        
        self.operationType = operationType
        self.httpBody = httpBody != nil ? httpBody! : ""
    }
    
    func runRequest(endpoint: String, completion: @escaping ((_ status: NStatusCode, _ data: Data?) -> Void)) {
        var request: URLRequest = URLRequest(url: URL.init(string: API.baseURL + endpoint)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        
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
                return
            }
            
//            print(String.init(data: data!, encoding: .utf8))
            
            guard let sc = (response as? HTTPURLResponse)?.statusCode, let code = NStatusCode.init(rawValue: sc) else {
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
                    print("Error LoginOperation: \n\tData unavailable")
                    return
                }
                
                let json = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as! [String : Any]
                
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
        
        if self.operationType == .get {
            print("Getting Settings...")
        }
        else {
            print("Pushing Settings...")
        }
        
        runRequest(endpoint: "settings") { (status, data) in
            
            switch status {
            case .ok:
                
                guard let d = data else {
                    API.shared.sendNotificationsFor(type: .settings, context: .error)
                    print("Error Settings Operation: \n\tData unavailable")
                    return
                }
                
                
                let decoder = JSONDecoder.init()
                decoder.dateDecodingStrategy = .formatted(Formatter.time)
                
                guard let settings = try? decoder.decode(Settings.self, from: d) else {
                    API.shared.sendNotificationsFor(type: .settings, context: .error)
                    print("Error Settings Operation: Unable to decode Settings")
                    return
                }
                Secret.shared.settings = settings
                
                if self.operationType == .get {
                    print("Settings Received and Saved!")
                }
                else {
                    print("Settings Pushed!")
                }
                
                API.shared.sendNotificationsFor(type: .settings, context: .success)
                
                break
                
            default:
                print("Error Settings Operation: \n\tStatusCode: \(status)")
                API.shared.sendNotificationsFor(type: .settings, context: .error)
                break
                
            }
            
        }
        
    }
    
}

class CalendarsOperation: NetworkOperation {
    
    override init() {
        super.init()
    }
    
    override func main() {
        super.main()
        
        if self.operationType == .get {
            print("Getting Calendars...")
        }
        else {
            print("Pushing Calendar...")
        }
        
        runRequest(endpoint: "calendars") { (status, data) in
            
            switch status {
            case .ok:
                
                guard let d = data else {
                    print("Error CalendarsOperation: \n\tData unavailable")
                    return
                }
                
                let decoder = JSONDecoder.init()
                decoder.dateDecodingStrategy = .formatted(Formatter.time)
                guard let calendars = try? decoder.decode([Calendars].self, from: d) else {
                    print("Error Calendars Operation: Unable to decode Calendars")
                    return
                }
                
                
                if self.operationType == .get {
                    
                    DispatchQueue(label: "background").async {
                        autoreleasepool {
                            let realm = try! Realm()
                            
                            try! realm.write {
                                realm.delete(realm.objects(Calendars.self))
                                realm.add(calendars)
                            }
                        }
                    }
                    
                    print("Calendars Received and Saved!")
                }
                else if self.operationType == .patch {
                    
                    DispatchQueue(label: "background").async {
                        autoreleasepool {
                            let realm = try! Realm()
                            
                            try! realm.write {
                                realm.delete(realm.objects(Calendars.self).filter(NSPredicate.init(format: "id=\(calendars.first!.id)")))
                                realm.add(calendars)
                            }
                        }
                    }
                    
                    print("Calendar Updated!")
                }
                else {
                    print("Calendar Pushed!")
                    
                    DispatchQueue(label: "background").async {
                        autoreleasepool {
                            let realm = try! Realm()
                            
                            try! realm.write {
                                realm.delete(realm.objects(Calendars.self).filter(NSPredicate.init(format: "id=\(calendars.first!.id)")))
                                realm.add(calendars)
                            }
                        }
                    }
                    
                }
                
                break
                
            default:
                print("Error Calendars Operation: \n\tStatusCode: \(status)")
                break
                
            }
            
        }
        
    }
    
}



