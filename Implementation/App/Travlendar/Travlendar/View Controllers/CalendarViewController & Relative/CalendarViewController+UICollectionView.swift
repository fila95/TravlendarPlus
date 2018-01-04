//
//  CalendarViewController+UICollectionView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 03/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit
import Utilities


extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let ev = self.events, ev.count > 0 else {
            return 0
        }
        
        if self.pickedDate.isToday {
            if section == 0 {
                return 1
            }
            else {
                return ev.count-1
            }
        }
        else {
            return ev.count
        }
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCollectionViewCell.reuseIdentifier, for: indexPath) as! EventCollectionViewCell
        if self.pickedDate.isToday {
            if indexPath.section == 0 {
                cell.setEvent(event: events![indexPath.row])
            }
            else {
                cell.setEvent(event: events![indexPath.row-1])
            }
        }
        else {
            cell.setEvent(event: events![indexPath.row])
        }
        return cell
        
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let ev = self.events, ev.count > 0 else {
            return 0
        }
        return self.pickedDate.isToday ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width-20, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidth: CGFloat = 300
        
        let numberOfCells = floor(self.view.frame.size.width / cellWidth)
        let edgeInsets = (self.view.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)
        
        return UIEdgeInsetsMake(10, edgeInsets, 10, edgeInsets)
    }
    
    // MARK: Headers
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            case UICollectionElementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeaderView.reuseIdentifier, for: indexPath) as! CollectionHeaderView
                
                headerView.titleLabel.text = "Later"
                if self.pickedDate.isToday {
                    if indexPath.section == 0 {
                        headerView.titleLabel.text = "Up Next"
                    }
                }
                
                return headerView
            default:
                assert(false, "Unexpected element kind")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width, height: 40)
    }
    
}