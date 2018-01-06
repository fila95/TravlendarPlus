//
//  DurationPickerComponent.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 06/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit
import ViewPresenter

class DurationPickerComponent: VPComponent {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var minusButton: RoundedButton!
    @IBOutlet var plusButton: RoundedButton!
    
    var value: Int = 0 {
        didSet {
            self.refreshValue()
        }
    }
    
    open override func desiredheight() -> CGFloat  {
        return 150
    }
    
    convenience init(value: Int) {
        self.init(frame: CGRect.zero)
        self.value = value
        commonInit()
    }
    
    override open func commonInit() {
        xibSetup()
        self.refreshValue()
    }
    
    func refreshValue() {
        if self.value < 0 {
            self.value = 0
        }
        
        let hrs = Int(Float(self.value) / 60)
        self.timeLabel.text = "\(hrs):\(self.value - hrs*60)"
    }
    
    @IBAction func minus(_ sender: Any) {
        self.value -= 10
        refreshValue()
    }
    @IBAction func plus(_ sender: Any) {
        self.value += 10
        refreshValue()
    }
}
