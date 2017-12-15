//
//  SettingsViewController+CollectionView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 14/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

extension SettingsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return calendars != nil ? calendars!.count : 0
        }
        
        return 1
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.reuseIdentifier, for: indexPath) as! CalendarCell
            
            cell.setCalendar(c: calendars![indexPath.row])
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddNewCollectionViewCell.reuseIdentifier, for: indexPath) as! AddNewCollectionViewCell
            cell.setText(text: "Add New...")
            return cell
        }
        
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize.init(width: 300, height: 77)
        }
        else {
            return CGSize.init(width: 240, height: 50)
        }
    }
    
}
