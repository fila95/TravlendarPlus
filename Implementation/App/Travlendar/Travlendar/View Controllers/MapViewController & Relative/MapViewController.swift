//
//  MapViewController.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 09/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let picker = CalendarPickerView()
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Date Picker View
        self.view.addSubview(picker)
        
        picker.setDateChangeHandler { (newDate) in
            print(newDate)
        }
        
        
        // Location Management
        Location.shared.requestAuthorizationIfNeeded { (complete) in
            
        }
        Location.shared.subscribe { (coordinates) in
            // Zoom to user location
            let viewRegion = MKCoordinateRegionMakeWithDistance(coordinates, 1000, 1000)
            self.map.setRegion(viewRegion, animated: false)
        }
        Location.shared.requestLocationUpdate()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            self.picker.setPickerType(type: .closed)
        }
    }
    
    
}


extension MapViewController: MKMapViewDelegate {
    
    
    
}
