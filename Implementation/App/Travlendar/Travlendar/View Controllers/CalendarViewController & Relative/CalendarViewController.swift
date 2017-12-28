//
//  CalendarViewController.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 09/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import DatePicker
import ViewPresenter


class CalendarViewController: UIViewController {
    
    let picker = CalendarPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Date Picker View
        self.view.addSubview(picker)
        picker.setDateChangeHandler { (newDate) in
            
            let v = VPButtonComponent(type: .strong, tapHandler: {
                print("tap")
            })
            let v1 = VPButtonComponent(type: .light, tapHandler: {
                print("tap2")
            })
            
            let vi = VPView(title: "Prova", components: [v, v1])
            
            
            let vp = VPViewPresenter(views: [vi])
            vp.modalPresentationStyle = .overCurrentContext
            self.present(vp, animated: true, completion: {
                
            })
            
        }
        
        
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            self.picker.setPickerType(type: .closed)
        }
    }
}

