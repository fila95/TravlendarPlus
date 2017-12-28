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
            
            
        }
        
        delay(5) {
            let vp = VPViewPresenter()
            for _ in 0...3 {
                
                let v1 = VPButtonComponent(type: .strong, text: "Ciao", tapHandler: {
                    print("tap2")
                })
                
                let vi = VPView(title: "Prova", components: [v1])
                vi.addComponent(component: VPButtonComponent.init(type: .light, text: "CIAOONE", tapHandler: {
                    vp.nextPage()
                }))
                vp.addView(view: vi)
            }
            
            let v1 = VPButtonComponent(type: .strong, text: "Ciao", tapHandler: {
                print("tap2")
            })
            
            let vi = VPView(title: "Prova", components: [v1])
            vi.addComponent(component: VPButtonComponent.init(type: .light, text: "CIAOONE", tapHandler: {
                vp.nextPage()
            }))
            vi.addComponent(component: VPButtonComponent.init(type: .light, text: "CIAOONE", tapHandler: {
                vp.showPage(page: 0)
            }))
            vp.addView(view: vi)
            
            
            
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

