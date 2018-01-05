//
//  EventComposerViewController+UITableView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit
import Utilities

extension EventComposerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 4
        case 3:
            return 2
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SaveCloseTableViewCell.reuseId, for: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.reuseId, for: indexPath) as! TextViewTableViewCell
            if indexPath.row == 0 {
                cell.setImage(image: #imageLiteral(resourceName: "address_image"))
            }
            else {
                cell.setImage(image: #imageLiteral(resourceName: "position_image"))
            }
            return cell
            
        case 2:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.reuseId, for: indexPath) as! SwitchTableViewCell
                cell.setTitle(text: "FlexibleTiming")
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: DateTableViewCell.reuseId, for: indexPath) as! DateTableViewCell
                if indexPath.row == 1 {
                    cell.setDate(date: Date())
                    cell.setTitle(title: "Start:")
                }
                else if indexPath.row == 2 {
                    cell.setDate(date: Date().addingTimeInterval(60))
                    cell.setTitle(title: "End:")
                }
                else if indexPath.row == 3 {
                    cell.setDuration(duration: 100)
                    cell.setTitle(title: "Duration:")
                }
                return cell
            }
        case 3:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SelectedCalendarTableViewCell.reuseId, for: indexPath) as! SelectedCalendarTableViewCell
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: RepetitionsTableViewCell.reuseId, for: indexPath) as! RepetitionsTableViewCell
                cell.setTitle(text: "Repetitions:")
                cell.setRepetitions(rep: 0b0101010)
                cell.setRepetitions(rep: "1010111")
                return cell
            }
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: AllowedVehiclesTableViewCell.reuseId, for: indexPath) as! AllowedVehiclesTableViewCell
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    
}


extension EventComposerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let c = tableView.dequeueReusableCell(withIdentifier: HeaderCell.reuseIdentifier) as! HeaderCell
        view.addSubview(c)
        
        switch section {
        case 1:
            c.titleLabel.text = "Event Details:"
            break
        case 2:
            c.titleLabel.text = "Timing:"
            break
        case 3:
            c.titleLabel.text = "Extra:"
            break
        case 4:
            c.titleLabel.text = "Allowed Vehicles:"
            break
        default:
            return nil
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 42
        case 4:
            return 120
        default:
            return 50
        }
        
    }
    
}
