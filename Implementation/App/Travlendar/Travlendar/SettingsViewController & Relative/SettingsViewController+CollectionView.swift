//
//  SettingsViewController+CollectionView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 14/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

extension SettingsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendars != nil ? calendars!.count : 0
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.reuseIdentifier, for: indexPath) as! CalendarCell
        
        cell.setCalendar(c: calendars![indexPath.row])
        return cell
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}
