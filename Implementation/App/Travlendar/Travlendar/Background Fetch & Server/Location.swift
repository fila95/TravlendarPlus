//
//  Location.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 27/11/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import CoreLocation

public protocol LocationDelegate {
    
    func location(didUpdateLocation coordinates: CLLocationCoordinate2D)
    
}

public class Location: NSObject {
    
    static let shared: Location = Location()
    
    
    private lazy var locationManager: CLLocationManager = {
        let m = CLLocationManager()
        m.activityType = .otherNavigation
        m.desiredAccuracy = 50
        m.allowsBackgroundLocationUpdates = true
        m.delegate = self
        return m
    }()
    
    override init() {
        super.init()
    }
    
    public func requestAuthorizationIfNeeded(completion: ((_ success: Bool) -> Void)) {
        guard CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied else {
            print("Location Services Not enabled...")
            completion(false)
            return
        }
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
        completion(true)
    }
    
    @objc
    public func requestLocationUpdate() {
        locationManager.startUpdatingLocation()
    }
    
    // MARK: Subscriptions
    var handlers = [(coordinates: CLLocationCoordinate2D) -> Void]()
    
    func subscribe(completion: @escaping (_ coordinates: CLLocationCoordinate2D) -> Void) {
        DispatchQueue.init(label: "io.array").async {
            self.handlers += [completion]
        }
    }
    
    
}

extension Location: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        guard locations.count > 0 else { return }
        
        for handle in handlers {
            DispatchQueue.init(label: "io.array").async {
                handle(locations[0].coordinate)
            }
        }
        
    }
    
}
