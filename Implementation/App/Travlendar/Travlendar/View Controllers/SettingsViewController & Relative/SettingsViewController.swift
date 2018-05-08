//
//  SettingsViewController.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 09/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import RealmSwift


class SettingsViewController: UIViewController {
    
    @IBOutlet weak var walkMaxDistanceSlider: UISlider!
    @IBOutlet weak var walkLabel: UILabel!
    @IBOutlet weak var bikeMaxDistanceSlider: UISlider!
    @IBOutlet weak var bikeLabel: UILabel!
    
    var notificationToken: NotificationToken?
    
    @IBOutlet weak var transitTimesPicker: UIPickerView!
    
    @IBOutlet weak var calendarsCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    var calendars: Results<Calendars>?
    
    deinit{
        //In latest Realm versions you just need to use this one-liner
        notificationToken?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitTimesPicker.delegate = self
        transitTimesPicker.dataSource = self
        
        calendarsCollectionView.register(CalendarCell.classForCoder(), forCellWithReuseIdentifier: CalendarCell.reuseIdentifier)
        calendarsCollectionView.register(UINib.init(nibName: "CalendarCell", bundle: Bundle.main), forCellWithReuseIdentifier: CalendarCell.reuseIdentifier)
        
        calendarsCollectionView.register(AddNewCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: AddNewCollectionViewCell.reuseIdentifier)
        calendarsCollectionView.register(UINib.init(nibName: "AddNewCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: AddNewCollectionViewCell.reuseIdentifier)
        
        calendarsCollectionView.delegate = self
        calendarsCollectionView.dataSource = self
        calendarsCollectionView.isScrollEnabled = false
        calendarsCollectionView.clipsToBounds = true
        
        refreshCalendars()
        refreshToSettings(s: Secret.shared.settings)
        
        let refreshSett: (() -> Void) = {
            DispatchQueue.main.async {
                self.refreshToSettings(s: Secret.shared.settings)
            }
        }
        
//        let refreshCal = {
//            DispatchQueue.main.async {
//                self.refreshCalendars()
//            }
//        }
        
        API.shared.addHandlers(handlers: [(refreshSett, type: .settings)])
        
        let realm = try! Realm()
        notificationToken = realm.observe { [unowned self] changes, realm in
<<<<<<< HEAD
            print("refresh")
=======
>>>>>>> f1624421c21454962bf076aa7a4da77865b016c0
            self.refreshCalendars()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.refreshCalendars()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshCalendars()
    }
    
    func refreshToSettings(s: Settings?) {
        guard let settings = s else {
            return
        }
        
        walkMaxDistanceSlider.value = settings.max_walking_distance
        walkLabel.text = String.init(format: "%.1fkm", settings.max_walking_distance/1000)
        
        bikeMaxDistanceSlider.value = settings.max_biking_distance
        bikeLabel.text = String.init(format: "%.1fkm", settings.max_biking_distance/1000)
        
        let calendar = Calendar.current
        var comp = calendar.dateComponents([.hour], from: settings.start_public_transportation)
        var hour = comp.hour!-1
        transitTimesPicker.selectRow(hour, inComponent: 0, animated: true)
        
        comp = calendar.dateComponents([.hour], from: settings.end_public_transportation)
        hour = comp.hour!-1
        transitTimesPicker.selectRow(hour, inComponent: 1, animated: true)
    }
    
    func refreshCalendars() {
        
        // Get the default Realm
        let realm = try! Realm()
        
        calendars = realm.objects(Calendars.self)
        calendarsCollectionView.reloadData()
        
        calendarsCollectionView.sizeToFit()
        collectionViewHeight.constant = calendarsCollectionView.contentSize.height
    }
    
    @IBAction func walkSliderEditValue(_ sender: UISlider) {
        walkLabel.text = String.init(format: "%.1fkm", sender.value/1000)
    }
    
    @IBAction func bikeSliderEditValue(_ sender: UISlider) {
        bikeLabel.text = String.init(format: "%.1fkm", sender.value/1000)
    }
    
    @IBAction func walkSliderChooseValue(_ sender: UISlider) {
        print("walkSliderChooseValue: \(sender.value)")
        guard let s = Secret.shared.settings else {
            return
        }
        
        s.max_walking_distance = sender.value
        Secret.shared.settings = s
        API.shared.pushSettingsToServer(settings: s)
    }
    
    @IBAction func bikeSliderChooseValue(_ sender: UISlider) {
        print("bikeSliderChooseValue: \(sender.value)")
        
        guard let s = Secret.shared.settings else {
            return
        }
        
        s.max_biking_distance = sender.value
        Secret.shared.settings = s
        API.shared.pushSettingsToServer(settings: s)
    }
}



extension SettingsViewController: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 24
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            if component == 0 {
                return "Start"
            }
            else if component == 1 {
                return "End"
            }
        }
        else {
            return "\(row)"
        }
        
        return ""
    }
    
}

extension SettingsViewController: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let right = pickerView.selectedRow(inComponent: 1)
        let left = pickerView.selectedRow(inComponent: 0)
        
        var editR = right == 0 ? 1 : right
        var editL = left == 0 ? 1 : left
        
        
        if editL >= editR {
            
            if editR - 1 > 0 {
                editL = editR - 1
            }
            else {
                editR = editL + 1
            }
            
//            editL = editR - 1 > 0 ? editR - 1 : editL
            
        }
        
        pickerView.selectRow(editR, inComponent: 1, animated: true)
        pickerView.selectRow(editL, inComponent: 0, animated: true)
        
        
        guard let s = Secret.shared.settings else {
            return
        }
        
        let frm = Formatter.time
        let dateL = frm.date(from: "\(editL):00:00")
        let dateR = frm.date(from: "\(editR):00:00")
        
        s.start_public_transportation = dateL!
        s.end_public_transportation = dateR!
        
        Secret.shared.settings = s
        API.shared.pushSettingsToServer(settings: s)
        
    }
    
}
