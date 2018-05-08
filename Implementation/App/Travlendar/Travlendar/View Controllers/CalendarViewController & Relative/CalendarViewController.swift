//
//  CalendarViewController.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 09/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import DatePicker
import ViewPresenter
import RealmSwift
//import Realm


class CalendarViewController: UIViewController {
    
    let picker = CalendarPickerView()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var verticalMargin: NSLayoutConstraint!
    
    var notificationToken: NotificationToken?
    
    var pickedDate: Date = Date().dateFor(.startOfDay)
    
    var previous: Results<Event>?
    var upNext: Results<Event>?
    var events: Results<Event>?
    
<<<<<<< HEAD
    deinit{
=======
    deinit {
>>>>>>> f1624421c21454962bf076aa7a4da77865b016c0
        //In latest Realm versions you just need to use this one-liner
        notificationToken?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(EventCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: EventCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib.init(nibName: "EventCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: EventCollectionViewCell.reuseIdentifier)
        
        collectionView.register(CollectionHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
        collectionView.register(UINib.init(nibName: "CollectionHeaderView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
        
        collectionView.contentInset.top = 20
        
        
        // Date Picker View
        self.view.addSubview(picker)
        picker.setDateChangeHandler { (newDate) in
            self.pickedDate = newDate
            self.refresh()
        }
        
        // Make sure picker does not overlap CollectionView
        picker.setResizeHandler { (animated) in
            self.refreshScrollInsets(animated: animated)
        }
        
        // Events Refresh
        
//        let refreshEvents: (() -> Void) = {
//            self.refresh()
//        }
//
//        let refreshCal = {
//            self.refresh()
//        }
//
//        API.shared.addHandlers(handlers: [(refreshEvents, type: .events), (refreshCal, type: .calendars)])
        
        let realm = try! Realm()
        notificationToken = realm.observe { [unowned self] changes, realm in
<<<<<<< HEAD
            print("refresh")
=======
>>>>>>> f1624421c21454962bf076aa7a4da77865b016c0
            self.refresh()
        }
        
        self.refresh()
    }
    
    private func refreshScrollInsets(animated: Bool) {
        let newHeight = self.picker.dragging ? self.picker.frame.size.height : self.picker.type.height() + self.view.safeAreaInsets.top
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.08, options: .curveEaseInOut, animations: {
                self.verticalMargin.constant = newHeight
            }, completion: { (complete) in
                
            })
        }
        else {
            self.verticalMargin.constant = newHeight
        }
    }
    
    func refresh() {
        DispatchQueue.main.async {
            
//            print("Refresh.......")
            
            // Get the default Realm
            let realm = try! Realm()
            realm.refresh()
            
            if self.pickedDate.isToday {
                var predicate = NSPredicate(format: "start_time >= %@ AND start_time <=  %@", Date() as NSDate, Date().addingTimeInterval(3600*3) as NSDate)
                self.upNext = realm.objects(Event.self).filter(predicate).sorted(byKeyPath: "start_time")
                
                
                predicate = NSPredicate(format: "start_time >= %@ AND start_time <=  %@", Date().addingTimeInterval(3600*3) as NSDate, Date().dateFor(.endOfDay) as NSDate)
                self.events = realm.objects(Event.self).filter(predicate).sorted(byKeyPath: "start_time")
                
                
                predicate = NSPredicate(format: "start_time >= %@ AND start_time <=  %@", Date().dateFor(.startOfDay) as NSDate, Date() as NSDate)
                self.previous = realm.objects(Event.self).filter(predicate).sorted(byKeyPath: "start_time")
                
//                print(self.upNext)
//                print(self.events)
//                print(self.previous)
            }
            else {
                self.upNext = nil
                self.previous = nil
                
                let predicate = NSPredicate(format: "start_time >= %@ AND start_time <=  %@", self.pickedDate.dateFor(.startOfDay) as NSDate, self.pickedDate.dateFor(.endOfDay) as NSDate)
                self.events = realm.objects(Event.self).filter(predicate).sorted(byKeyPath: "start_time")
            }
            
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Make sure picker does not overlap CollectionView
        self.refreshScrollInsets(animated: false)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            self.picker.setPickerType(type: .closed)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let ec = EventComposerViewController()
        self.tabBarController?.present(ec, animated: true) {

        }
    }
}

