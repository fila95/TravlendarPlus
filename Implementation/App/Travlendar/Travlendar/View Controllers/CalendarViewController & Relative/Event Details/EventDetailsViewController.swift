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
import RealmSwift

class EventDetailsViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapViewHeight: NSLayoutConstraint!
    
    var notificationToken: NotificationToken?
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView!
    
    var event: Event? {
        didSet {
            if event != nil {
//                print(event ?? "")
                self.id = event!.id
                self.refresh()
            }
        }
    }
    
    var id: Int?
    
    deinit{
        //In latest Realm versions you just need to use this one-liner
        notificationToken?.invalidate()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.collectionView.register(RoutesCollectionViewCell.self, forCellWithReuseIdentifier: RoutesCollectionViewCell.reuseId)
        self.collectionView.register(RoutesCollectionViewCell.nib!, forCellWithReuseIdentifier: RoutesCollectionViewCell.reuseId)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        
//        // Events Refresh
//        let refreshEvents: (() -> Void) = {
//            self.refreshEvent()
//
//        }

        
//        let refreshCal = {
//            self.refreshEvent()
//        }
//        API.shared.addHandlers(handlers: [(refreshEvents, type: .events), (refreshCal, type: .calendars)])
//
        
        let realm = try! Realm()
        notificationToken = realm.observe { [unowned self] changes, realm in
            self.refreshEvent()
        }
        
        self.refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func refreshEvent() {
        
        DispatchQueue.main.async {
            if self.id != nil {
                let realm = try! Realm()
                self.event = realm.object(ofType: Event.self, forPrimaryKey: self.id!)
            }
            
            self.refresh()
        }
        
    }
    
    private func refresh() {
        
        DispatchQueue.main.async {
            guard self.presentationController != nil else {
                return
            }
            
            
            guard let e = self.event else {
                return
            }
            
            self.nameLabel.text = e.title
            
            if e.address == "" && e.lat == 1 && e.lng == 1 {
                self.addressLabel.text = ""
                self.mapViewHeight.constant = 10
                self.mapView.isHidden = true
                
                e.relativeCalendar(completion: { (cal) in
                    if cal != nil {
                        DispatchQueue.main.async {
                            self.addressLabel.text = "Found in: \(cal!.name)"
                        }
                    }
                })
            }
            else {
                self.addressLabel.text = e.address
                self.mapViewHeight.constant = 120
                self.mapView.isHidden = false
                
                for a in self.mapView.annotations {
                    if !(a is MKUserLocation) {
                        self.mapView.removeAnnotation(a)
                    }
                }
                
                let coords = CLLocationCoordinate2D.init(latitude: e.lat, longitude: e.lng)
                let a = MKPointAnnotation.init()
                a.coordinate = coords
                self.mapView.addAnnotation(a)
                
                let region = MKCoordinateRegionMakeWithDistance(coords, 300, 300)
                self.mapView.setRegion(region, animated: true)
            }
            
            if e.suggested_start_time == Event.defaultSuggestionDate && e.suggested_end_time == Event.defaultSuggestionDate {
                self.dateLabel.text = Formatter.readableDate.string(from: e.start_time)
                self.timeLabel.text = "\(Formatter.timeShort.string(from: e.start_time)) - \(Formatter.timeShort.string(from: e.end_time))"
            }
            else {
                self.dateLabel.text = Formatter.readableDate.string(from: e.suggested_start_time)
                self.timeLabel.text = "\(Formatter.timeShort.string(from: e.suggested_start_time)) - \(Formatter.timeShort.string(from: e.suggested_end_time))"
            }
            
            self.refreshCollectionView()
        }
        
    }
    
    private func refreshCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            delay(0.3, closure: {
                UIView.animate(withDuration: 0.5, animations: {
                    self.collectionViewHeight.constant = self.collectionView.contentSize.height < 20 ? 200 : self.collectionView.contentSize.height
                })
                
            })
            
        }
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
