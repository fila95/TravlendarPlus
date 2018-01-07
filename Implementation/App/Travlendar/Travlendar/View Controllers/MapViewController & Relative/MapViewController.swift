//
//  MapViewController.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 09/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class MapViewController: UIViewController {
    
    let picker = CalendarPickerView()
    @IBOutlet weak var map: MKMapView!
    
    private var currentDate = Date()
    private var events: Results<Event>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Map
        self.map.tintColor = UIColor.application
        
        // Date Picker View
        self.view.addSubview(picker)
        
        picker.setDateChangeHandler { (newDate) in
            self.currentDate = newDate
            self.refreshUptoDate()
            
        }
        
        // Location Management
        Location.shared.requestAuthorizationIfNeeded { (complete) in
            
        }
        Location.shared.subscribe { (coordinates) in
            // Zoom to user location
            self.map.fitAllMarkers(shouldIncludeCurrentLocation: true)
        }
        Location.shared.requestLocationUpdate()
        
        self.refreshUptoDate()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            self.picker.setPickerType(type: .closed)
        }
    }
    
    func refreshUptoDate(newDate: Date? = nil) {
        DispatchQueue.main.async { [unowned self] in
            if newDate != nil {
                self.currentDate = newDate!
            }
            
            // Refresh View known Current Date
            let realm = try! Realm()
            
            let predicate = NSPredicate(format: "start_time >= %@ AND end_time <=  %@", self.currentDate.dateFor(.startOfDay) as NSDate, self.currentDate.dateFor(.endOfDay) as NSDate)
            self.events = realm.objects(Event.self).filter(predicate).sorted(byKeyPath: "start_time")
            self.refreshAnnotations()
        }
    }
    
    private func refreshAnnotations() {
        DispatchQueue.main.async {
            guard let ev = self.events else {
                return
            }
            self.map.removeOverlays(self.map.overlays)
            self.map.removeAnnotations(self.map.annotations)
            
            for e in ev {
                let ann = MKPointAnnotation()
                ann.coordinate = CLLocationCoordinate2D(latitude: e.lat, longitude: e.lng)
                self.map.addAnnotation(ann)
            }
            
            self.map.fitAllMarkers(shouldIncludeCurrentLocation: true)
            self.showRouteOnMap()
        }
    }
    
    func showRouteOnMap() {
        DispatchQueue.main.async {
            let c = self.map.annotations.count
            
            for idx in 0..<c {
                guard idx+1 < c else {
                    return
                }
                
                let a = self.map.annotations[idx]
                let a1 = self.map.annotations[idx+1]
                
                let request = MKDirectionsRequest()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: a.coordinate, addressDictionary: nil))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: a1.coordinate, addressDictionary: nil))
                request.requestsAlternateRoutes = true
                request.transportType = .any
                
                let directions = MKDirections(request: request)
                
                
                directions.calculate(completionHandler: { (response, error) in
                    guard let unwrappedResponse = response else { return }
                    
                    if (unwrappedResponse.routes.count > 0) {
                        self.map.add(unwrappedResponse.routes[0].polyline)
                        self.map.setVisibleMapRect(unwrappedResponse.routes[0].polyline.boundingMapRect, animated: true)
                    }
                })
                
                
                
                
            }
        }
    }
    
    
    
    
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.generateVibrantColor()
            polylineRenderer.lineWidth = 3
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
    
    
}


extension MKMapView {
    
    func fitAllMarkers(shouldIncludeCurrentLocation: Bool) {
        
        if !shouldIncludeCurrentLocation {
            showAnnotations(annotations, animated: true)
        }
        else {
            var zoomRect = MKMapRectNull
            
            let point = MKMapPointForCoordinate(userLocation.coordinate)
            let pointRect = MKMapRectMake(point.x, point.y, 0, 0)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
            
            for annotation in annotations {
                
                let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
                let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
                
                if (MKMapRectIsNull(zoomRect)) {
                    zoomRect = pointRect
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, pointRect)
                }
            }
            
            setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(150, 10, 10, 10), animated: true)
        }
    }
    
}
