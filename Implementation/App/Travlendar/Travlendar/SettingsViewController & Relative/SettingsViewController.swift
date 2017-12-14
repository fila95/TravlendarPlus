//
//  SettingsViewController.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 09/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit


class SettingsViewController: UIViewController {
    
    @IBOutlet weak var walkMaxDistanceSlider: UISlider!
    @IBOutlet weak var walkLabel: UILabel!
    @IBOutlet weak var bikeMaxDistanceSlider: UISlider!
    @IBOutlet weak var bikeLabel: UILabel!
    
    @IBOutlet weak var transitTimesPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        s.max_walking_distance = sender.value / 1000
        Secret.shared.settings = s
        API.shared.pushSettingsToServer(settings: s)
    }
    
    @IBAction func bikeSliderChooseValue(_ sender: UISlider) {
        print("bikeSliderChooseValue: \(sender.value)")
    }
}

