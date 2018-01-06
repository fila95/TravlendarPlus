//
//  CalendarPickerComponent.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 06/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit
import ViewPresenter
import RealmSwift

class CalendarPickerComponent: VPComponent {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentCalendar: Int = -1 {
        didSet {
            self.refreshCurrentCalendar()
        }
    }
    private var calendars: Results<Calendars>?
    

    
    override func desiredheight() -> CGFloat {
        return 300
    }
    
    convenience init(calendar: Int) {
        self.init(frame: CGRect.zero)
        self.currentCalendar = calendar
        commonInit()
    }
    
    override func commonInit() {
        xibSetup()
        collectionView.register(CalendarPickerCollectionViewCell.self, forCellWithReuseIdentifier: CalendarPickerCollectionViewCell.reuseId)
        collectionView.register(CalendarPickerCollectionViewCell.nib!, forCellWithReuseIdentifier: CalendarPickerCollectionViewCell.reuseId)
        
        self.refreshCurrentCalendar()
    }
    
    private func refreshCurrentCalendar() {
        DispatchQueue.main.async {
            // Get the default Realm
            let realm = try! Realm()
            self.calendars = realm.objects(Calendars.self).sorted(byKeyPath: "name")
            
            self.collectionView.reloadData()
        }
    }

}


extension CalendarPickerComponent: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendars?.count ?? 0
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarPickerCollectionViewCell.reuseId, for: indexPath) as! CalendarPickerCollectionViewCell
        let c = calendars![indexPath.row]
        cell.setCalendar(c: c)
        if c.id == self.currentCalendar {
            cell.isSelected = true
        }
        return cell
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentCalendar = calendars![indexPath.row].id
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width-20, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidth: CGFloat = self.frame.size.width - 20
        
        let numberOfCells = floor(self.frame.size.width / cellWidth)
        let edgeInsets = (self.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)
        
        return UIEdgeInsetsMake(10, edgeInsets, 10, edgeInsets)
    }
    
    
    
}
