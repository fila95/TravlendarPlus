//
//  CalendarViewController.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 09/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import DatePicker


class CalendarViewController: UIViewController {
    
    let picker = CalendarPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(picker)
//        
//        delay(2) {
//            self.picker.setPickerType(type: .open, animated: true)
//        }
//        delay(4) {
//            self.picker.setPickerType(type: .closed, animated: true)
//        }
    }
    
    
}

