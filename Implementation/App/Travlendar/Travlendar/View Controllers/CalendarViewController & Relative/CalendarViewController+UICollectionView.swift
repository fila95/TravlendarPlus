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
        
        if section == 0 {
            if self.previous != nil && self.previous!.count != 0 {
                return self.previous!.count
            }
        }
        else if section == 1  {
            if self.upNext != nil && self.upNext!.count != 0 {
                return self.upNext!.count
            }
        }
        else if section == 2  {
            if self.events != nil && self.events!.count != 0 {
                return self.upNext!.count
            }
        }

        return 0
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCollectionViewCell.reuseIdentifier, for: indexPath) as! EventCollectionViewCell
        if indexPath.section == 0 {
            if self.previous != nil && self.previous!.count != 0 {
                cell.setEvent(event: self.previous![indexPath.row])
            }
            
        }
        else if indexPath.section == 1  {
            if self.upNext != nil && self.upNext!.count != 0 {
                cell.setEvent(event: self.upNext![indexPath.row])
            }
            
        }
        else if indexPath.section == 2  {
            if self.events != nil && self.events!.count != 0 {
                cell.setEvent(event: self.events![indexPath.row])
            }
            
        }
        return cell
        
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailsViewController
        
        
        if indexPath.section == 0 {
            vc.event = self.previous![indexPath.row]
        }
        else if indexPath.section == 1 {
            vc.event = self.upNext![indexPath.row]
        }
        else if indexPath.section == 2 {
            vc.event = self.events![indexPath.row]
        }
        
        
        self.navigationController?.pushViewController(vc, animated: true)
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
                headerView.titleLabel.text = ""
                
                if indexPath.section == 0 {
                    if self.previous != nil && self.previous!.count != 0 {
                        headerView.titleLabel.text = "Previous"
                    }
                    
                }
                else if indexPath.section == 1  {
                    if self.upNext != nil && self.upNext!.count != 0 {
                        headerView.titleLabel.text = "Up Next"
                    }
                    
                }
                else if indexPath.section == 2  {
                    if self.events != nil && self.events!.count != 0 {
                        headerView.titleLabel.text = "Later"
                    }
                    
                }
                
                return headerView
            default:
                assert(false, "Unexpected element kind")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            if !(self.previous != nil && self.previous!.count != 0) {
                return CGSize.init(width: collectionView.frame.size.width, height: 0)
            }
            
        }
        else if section == 1  {
            if !(self.upNext != nil && self.upNext!.count != 0) {
                return CGSize.init(width: collectionView.frame.size.width, height: 0)
            }
        }
        else if section == 2  {
            if !(self.events != nil && self.events!.count != 0) {
                return CGSize.init(width: collectionView.frame.size.width, height: 0)
            }
        }
        
        return CGSize.init(width: collectionView.frame.size.width, height: 40)
    }
    
}
