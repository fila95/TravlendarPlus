//
//  EventDetailsViewController.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 06/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit
import MapKit
import Utilities

class EventDetailsViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView!
    
    var event: Event? {
        didSet {
            self.refresh()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func refresh() {
        guard self.presentationController != nil else {
            return
        }
        guard let e = self.event else {
            return
        }
        
        self.nameLabel.text = e.title
        self.addressLabel.text = e.address
        
        self.dateLabel.text = Formatter.readableDate.string(from: e.start_time)
        self.timeLabel.text = "\(Formatter.timeShort.string(from: e.start_time)) - \(Formatter.timeShort.string(from: e.end_time))"
        
        mapView.removeAnnotations(self.mapView.annotations)
        
        let coords = CLLocationCoordinate2D.init(latitude: e.lat, longitude: e.lng)
        let a = MKPointAnnotation.init()
        a.coordinate = coords
        self.mapView.addAnnotation(a)
        
        let region = MKCoordinateRegionMakeWithDistance(coords, 300, 300)
        self.mapView.setRegion(region, animated: true)
    }
    

    @IBAction func editEvent(_ sender: Any) {
        guard let e = self.event else {
            return
        }
        
        let ec = EventComposerViewController()
        
        let decoder = JSONDecoder.init()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        
        let encoder = JSONEncoder.init()
        encoder.dateEncodingStrategy = .formatted(Formatter.iso8601)
        
        guard let encoded = try? encoder.encode(e) else {
            return
        }
        guard let decoded = try? decoder.decode(Event.self, from: encoded) else {
            return
        }
        
        ec.setEvent(e: decoded)
        self.tabBarController?.present(ec, animated: true) {
            
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension EventDetailsViewController: MKMapViewDelegate {
    
    //MARK:- MapViewDelegate methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        
        if overlay is MKPolyline {
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            
        }
        return polylineRenderer
    }
    
    
}
