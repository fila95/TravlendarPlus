//
//  EventComposerViewController+UITableView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit
import Utilities
import ViewPresenter

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
                cell.setTitle(text: "Flexible Timing:")
                cell.setSwitchOn(on: currentEvent.duration != -1)
                cell.accessoryType = .none
                self.prepareDurationSwitchHandler(cell: cell)
                return cell
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            
            if indexPath.row != 0 {
                let vp = VPViewPresenter()
                let vpv = VPView()
                
                if indexPath.row == 1 {
                    vpv.titleText = "Start Date"
                    let datePicker = VPDatePickerComponent(date: self.currentEvent.start_time)
                    vpv.addComponent(component: datePicker)
                    vpv.addComponent(component: VPButtonComponent(type: .strong, text: "Ok", tapHandler: { (button) in
                        self.currentEvent.start_time = datePicker.date
                        
                        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        vp.dismiss(animated: true, completion: nil)
                    }))
                    
                }
                else if indexPath.row == 2 {
                    vpv.titleText = "End Date"
                    let datePicker = VPDatePickerComponent(date: self.currentEvent.end_time)
                    datePicker.datePicker.minimumDate = self.currentEvent.start_time.addingTimeInterval(60)
                    vpv.addComponent(component: datePicker)
                    vpv.addComponent(component: VPButtonComponent(type: .strong, text: "Ok", tapHandler: { (button) in
                        self.currentEvent.end_time = datePicker.date
                        
                        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        vp.dismiss(animated: true, completion: nil)
                    }))
                }
                else if indexPath.row == 3 {
                    vpv.titleText = "Duration"
                    let valuePicker = DurationPickerComponent(value: self.currentEvent.duration)
                    vpv.addComponent(component: valuePicker)
                    vpv.addComponent(component: VPButtonComponent(type: .strong, text: "Ok", tapHandler: { (button) in
                        self.currentEvent.duration = valuePicker.value
                        
                        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        vp.dismiss(animated: true, completion: nil)
                    }))
                    
                }
                
                vpv.addComponent(component: VPButtonComponent(type: .light, text: "Close", tapHandler: { (button) in
                    vp.dismiss(animated: true, completion: nil)
                }))
                vp.addView(view: vpv)
                self.present(vp, animated: true, completion: nil)
            }
            
        }
        else if indexPath.section == 3 {
            
            let vp = VPViewPresenter()
            let vpv = VPView()
            
            if indexPath.row == 0 {
                vpv.titleText = "Calendar"
                let calendarPicker = CalendarPickerComponent(calendar: self.currentEvent.calendar_id)
                vpv.addComponent(component: calendarPicker)
                vpv.addComponent(component: VPButtonComponent(type: .strong, text: "Ok", tapHandler: { (button) in
                    self.currentEvent.calendar_id = calendarPicker.currentCalendar
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    vp.dismiss(animated: true, completion: nil)
                }))
            }
            else {
                vpv.titleText = "Repetitions"
                let repetitionsPicker = RepetitionsPickerComponent(repetitions: self.currentEvent.repetitions)
                vpv.addComponent(component: repetitionsPicker)
                vpv.addComponent(component: VPButtonComponent(type: .strong, text: "Ok", tapHandler: { (button) in
                    self.currentEvent.repetitions = repetitionsPicker.getRepetitions()
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    vp.dismiss(animated: true, completion: nil)
                }))
            }
            
            vpv.addComponent(component: VPButtonComponent(type: .light, text: "Close", tapHandler: { (button) in
                vp.dismiss(animated: true, completion: nil)
            }))
            vp.addView(view: vpv)
            self.present(vp, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    
}

// MARK: Cell Handlers
extension EventComposerViewController {
    
    func prepareSaveCloseHandlers(cell: SaveCloseTableViewCell) {
        cell.setSaveHandler {
            self.save()
        }
        
        cell.setCloseHandler {
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
        
        let saveCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SaveCloseTableViewCell
        saveCell.saveButton.loading = true
        
        
        guard let eventName = (self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! TextViewTableViewCell).textField.text, eventName != "" else {
            UIAlertController.show(title: "Error", message: "You should type a name in order to continue.", buttonTitle: "Ok", on: self)
            saveCell.saveButton.loading = false
            return
        }
        self.currentEvent.title = eventName
        
        guard let eventAddress = (self.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! TextViewTableViewCell).textField.text, eventAddress != "" else {
            UIAlertController.show(title: "Error", message: "You should type an address in order to continue.", buttonTitle: "Ok", on: self)
            saveCell.saveButton.loading = false
            return
        }
        self.currentEvent.address = eventAddress
        
        self.currentEvent.transports = (self.tableView.cellForRow(at: IndexPath(row: 0, section: 4)) as! AllowedVehiclesTableViewCell).getAllowedVehicles()
        guard self.currentEvent.transports.contains("1") else {
            UIAlertController.show(title: "Error", message: "You should select at least one transport mean in order to continue.", buttonTitle: "Ok", on: self)
            saveCell.saveButton.loading = false
            return
        }
        
        guard self.currentEvent.calendar_id >= 0 else {
            UIAlertController.show(title: "Error", message: "You should select a calendar in order to continue. If you don't have one just add it from settings view!", buttonTitle: "Ok", on: self)
            saveCell.saveButton.loading = false
            return
        }
        
        guard self.currentEvent.start_time < self.currentEvent.end_time else {
            UIAlertController.show(title: "Error", message: "Start and end dates selected results incorrect...", buttonTitle: "Ok", on: self)
            saveCell.saveButton.loading = false
            return
        }
        
//        print(currentEvent)
        
        
        if self.creatingNew {
            API.shared.addEvent(event: self.currentEvent, completion: { (complete, error) in
                DispatchQueue.main.async {
                    saveCell.saveButton.loading = false
                    
                    if complete {
                        self.dismiss(animated: true)
                    }
                    else {
                        UIAlertController.show(title: "Error", message: "An error occurred while adding this event", buttonTitle: "Ok", on: self)
                    }
                }
                
            })
        }
        else {
            DispatchQueue.main.async {
                API.shared.updateEvent(event: self.currentEvent, completion: { (complete, error) in
                    saveCell.saveButton.loading = false
                    
                    if complete {
                        self.dismiss(animated: true)
                    }
                    else {
                        UIAlertController.show(title: "Error", message: "An error occurred while updating this event", buttonTitle: "Ok", on: self)
                    }
                    
                })
            }
        }
        
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
