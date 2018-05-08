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
                return self.events!.count
            }
        }

        return 0
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCollectionViewCell.reuseIdentifier, for: indexPath) as! EventCollectionViewCell
        
        var e: Event!
        if indexPath.section == 0 {
            if self.previous != nil && self.previous!.count != 0 {
                e = self.previous![indexPath.row]
                cell.setEvent(event: e)
            }
        }
        else if indexPath.section == 1  {
            if self.upNext != nil && self.upNext!.count != 0 {
                e = self.upNext![indexPath.row]
                cell.setEvent(event: e)
            }
            
        }
        else if indexPath.section == 2  {
            if self.events != nil && self.events!.count != 0 {
                e = self.events![indexPath.row]
                cell.setEvent(event: e)
            }
        }
        
        
        
        cell.setLongPressHandler {
            let ac = UIAlertController(title: "Warning", message: "Are you sure you want to delete this event?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in }))
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                API.shared.deleteEventFromServer(event: e, completion: { (complete, message) in
                    if complete {
                        API.shared.triggerSync()
                        self.refresh()
                    }
                    else {
                        // Error
                        print(message as Any)
                        UIAlertController.show(title: "Error", message: "Error deleting event...", buttonTitle: "Cancel", on: self)
                    }
                    
                })
            }))
            self.present(ac, animated: true, completion: {
                
            })
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
        let cellWidth: CGFloat = collectionView.frame.size.width - 20
        
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
                headerView.titleLabel.isHidden = true
                
                if indexPath.section == 0 {
                    if self.previous != nil && self.previous!.count != 0 {
                        headerView.titleLabel.text = "Previous"
                        headerView.titleLabel.isHidden = false
                    }
                    
                }
                else if indexPath.section == 1  {
                    if self.upNext != nil && self.upNext!.count != 0 {
                        headerView.titleLabel.text = "Up Next"
                        headerView.titleLabel.isHidden = false
                    }
                    
                }
                else if indexPath.section == 2  {
                    if self.events != nil && self.events!.count != 0 {
                        headerView.titleLabel.text = "Later"
                        headerView.titleLabel.isHidden = false
                    }
                    
                }
                
                return headerView
            default:
                assert(false, "Unexpected element kind")
        }
        
        return UICollectionReusableView()
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
