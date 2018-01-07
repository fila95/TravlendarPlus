//
//  SettingsViewController+CollectionView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 14/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import ViewPresenter
import Utilities
import RealmSwift

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
            cell.setCalendar(c: self.calendars![indexPath.row])
            
            cell.setLongPressHandler {
                let index = indexPath.row
                let ac = UIAlertController(title: "Warning", message: "Are you sure you want to delete this calendar?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in }))
                ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    API.shared.deleteCalendarFromServer(calendar: self.calendars![index], completion: { (complete, message) in
                        if complete {
                            DispatchQueue.main.async {
                                API.shared.triggerSync()
                                self.refreshCalendars()
                            }
                            
                        }
                        else {
                            // Error
                            print(message as Any)
                            UIAlertController.show(title: "Error", message: "Error deleting calendar...", buttonTitle: "Cancel", on: self)
                        }
                        
                    })
                }))
                self.present(ac, animated: true, completion: {
                    
                })
            }
            
            
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
        
        
        let viewPresenter = VPViewPresenter()
        
        let colorView = VPView.init(title: "Color")
        let calendarView = VPView.init(title: "Calendar")
        
        let c = indexPath.section == 0 ? UIColor.init(hex: calendars![indexPath.row].color) : UIColor.generateRandomColor()
        let text = indexPath.section == 0 ? calendars![indexPath.row].name : ""
        let creatorView = CalendarCreatorView(color: c, name: text)
        let colorPicker = CalendarColorPickerView(color: c)
        
        colorView.addComponent(component: colorPicker)
        colorView.addComponent(component: VPButtonComponent(type: .strong, text: "Ok", tapHandler: { (sender) in
            creatorView.color = colorPicker.color
            viewPresenter.previousPage()
        }))
        
        // CalendarView
        calendarView.components = [creatorView]
        calendarView.addComponent(component: VPLoadingButtonComponent(type: .strong, text: "Save", tapHandler: { (sender) in
            let s = sender as! VPLoadingButtonComponent
            s.isLoading = true
            
            let name = creatorView.textField.text ?? ""
            let color = creatorView.color.toHexString()
            
            if indexPath.section == 0 {
                // Edit
                let calRef = ThreadSafeReference(to: self.calendars![indexPath.row])
                
                Database.shared.realm(completion: { (realm) in
                    guard let calendar = realm.resolve(calRef) else {
                        return // person was deleted
                    }
                    
                    try! realm.write {
                        calendar.name = name
                        calendar.color = color
                        
                        API.shared.updateCalendar(calendar: calendar, completion: { (complete, message) in
                            s.isLoading = false
                            
                            if complete {
                                DispatchQueue.main.async {
                                    viewPresenter.dismiss(animated: true, completion: {
                                        
                                    })
                                }
                                
                            }
                            else {
                                // Error
                                print(message as Any)
                                UIAlertController.show(title: "Error", message: "Error updating calendar...", buttonTitle: "Cancel", on: self)
                            }
                        })
                    }
                })
                
            }
            else {
                // Create new
                Database.shared.realm(completion: { (realm) in
                    
                    let cal = Calendars()
                    cal.name = name
                    cal.color = color
                    API.shared.addCalendar(calendar: cal, completion: { (complete, message) in
                        s.isLoading = false
                        if complete {
                            DispatchQueue.main.async {
                                viewPresenter.dismiss(animated: true, completion: {
                                    
                                })
                            }
                            
                        }
                        else {
                            // Error
                            print(message as Any)
                            UIAlertController.show(title: "Error", message: "Error adding calendar...", buttonTitle: "Cancel", on: self)
                        }
                    })
                    
                })
            }
            
        }))
        calendarView.addComponent(component: VPButtonComponent(type: .light, text: "Close", tapHandler: { (sender) in
            viewPresenter.dismiss(animated: true, completion: nil)
        }))
        
        viewPresenter.addView(view: calendarView)
        viewPresenter.addView(view: colorView)
        
        
        self.present(viewPresenter, animated: true) {
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize.init(width: 300, height: 77)
        }
        else {
            return CGSize.init(width: 220, height: 50)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let cellWidth: CGFloat = section == 0 ? 300 : 240
        
        let numberOfCells = floor(self.view.frame.size.width / cellWidth)
        let edgeInsets = (self.view.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)
        
        return UIEdgeInsetsMake(10, edgeInsets, 10, edgeInsets)
    }
    
    
}
