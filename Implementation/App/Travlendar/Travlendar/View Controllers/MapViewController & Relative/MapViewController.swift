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
        
        self.view.addSubview(picker)
    }
    
}


extension MapViewController: MKMapViewDelegate {
    
    
    
}
