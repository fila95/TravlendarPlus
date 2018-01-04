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


class CalendarViewController: UIViewController {
    
    let picker = CalendarPickerView()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var verticalMargin: NSLayoutConstraint!
    
    var pickedDate: Date = Date().dateFor(.startOfDay)
    var events: Results<Event>?
    
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
        
        let refreshEvents: (() -> Void) = {
            self.refresh()
        }
        
        let refreshCal = {
            self.refresh()
        }
        
        API.shared.addHandlers(handlers: [(refreshEvents, type: .events), (refreshCal, type: .calendars)])
        
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
    
    private func refresh() {
        DispatchQueue.main.async {
            // Get the default Realm
            let realm = try! Realm()
            
            let predicate = NSPredicate(format: "start_time >= %@ AND end_time <=  %@", self.pickedDate.dateFor(.startOfDay) as NSDate, self.pickedDate.dateFor(.endOfDay) as NSDate)
            self.events = realm.objects(Event.self).filter(predicate)
//            print(self.events ?? "no events")
            
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        self.present(ec, animated: true) {
            
        }
    }
}

