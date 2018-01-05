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
            if currentEvent.duration != -1 {
                return 4
            }
            return 3
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
            let cell = tableView.dequeueReusableCell(withIdentifier: SaveCloseTableViewCell.reuseId, for: indexPath) as! SaveCloseTableViewCell
            self.prepareSaveCloseHandlers(cell: cell)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.reuseId, for: indexPath) as! TextViewTableViewCell
            if indexPath.row == 0 {
                cell.setImage(image: #imageLiteral(resourceName: "address_image"))
                cell.setText(text: currentEvent.title)
                cell.setPlaceholder(text: "Event Name")
            }
            else {
                cell.setImage(image: #imageLiteral(resourceName: "position_image"))
                cell.setText(text: currentEvent.address)
                cell.setPlaceholder(text: "Address")
            }
            return cell
            
        case 2:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.reuseId, for: indexPath) as! SwitchTableViewCell
                cell.setTitle(text: "FlexibleTiming")
                cell.setSwitchOn(on: currentEvent.duration != -1)
                self.prepareDurationSwitchHandler(cell: cell)
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: DateTableViewCell.reuseId, for: indexPath) as! DateTableViewCell
                if indexPath.row == 1 {

                    cell.setDate(date: currentEvent.start_time)
                    cell.setTitle(title: "Start:")
                }
                else if indexPath.row == 2 {
                    cell.setDate(date: currentEvent.end_time)
                    cell.setTitle(title: "End:")
                }
                else if indexPath.row == 3 {
                    cell.setTitle(title: "Duration:")
                    cell.setDuration(duration: currentEvent.duration)
                }
                return cell
            }
        case 3:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SelectedCalendarTableViewCell.reuseId, for: indexPath) as! SelectedCalendarTableViewCell
                self.currentEvent.relativeCalendar(completion: { (cal) in
                    cell.setCalendar(cal: cal)
                })
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: RepetitionsTableViewCell.reuseId, for: indexPath) as! RepetitionsTableViewCell
                cell.setTitle(text: "Repetitions:")
                cell.setRepetitions(rep: self.currentEvent.repetitions)
                return cell
            }
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: AllowedVehiclesTableViewCell.reuseId, for: indexPath) as! AllowedVehiclesTableViewCell
            cell.setAllowedVehicles(rep: self.currentEvent.transports)
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

// MARK: Cell Handlers
extension EventComposerViewController {
    
    func prepareSaveCloseHandlers(cell: SaveCloseTableViewCell) {
        cell.setSavehandler {
            self.save()
        }
        
        cell.setClosehandler {
            self.dismiss(animated: true)
        }
    }
    
    func prepareDurationSwitchHandler(cell: SwitchTableViewCell) {
        cell.setSwitchChangedHandler {
            if cell.switchView.isOn {
                self.currentEvent.duration = 0
                self.tableView.insertRows(at: [IndexPath.init(row: 3, section: 2)], with: UITableViewRowAnimation.automatic)
            }
            else {
                self.currentEvent.duration = -1
                self.tableView.deleteRows(at: [IndexPath.init(row: 3, section: 2)], with: UITableViewRowAnimation.automatic)
            }
        }
    }
    
}



// MARK: Save and Checks
extension EventComposerViewController {
    
    func save() {
        
        
        
    }
    
}

// MARK: Table Delegate

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
