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
        
        
        // Date Picker View
        self.view.addSubview(picker)
        picker.setDateChangeHandler { (newDate) in
            print(newDate)
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            self.picker.setPickerType(type: .closed)
        }
    }
}

