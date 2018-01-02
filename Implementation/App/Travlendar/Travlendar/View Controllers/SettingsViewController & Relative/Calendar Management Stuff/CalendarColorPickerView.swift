//
//  CalendarColorPickerView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 02/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit
import ViewPresenter

class CalendarColorPickerView: VPComponent {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    var color: UIColor = UIColor.green {
        didSet {
            self.refreshColor()
        }
    }
    
    open override func desiredheight() -> CGFloat  {
        return 200
    }
    
    convenience init(color: UIColor) {
        self.init(frame: CGRect.zero)
        self.color = color
        commonInit()
    }
    
    override open func commonInit() {
        xibSetup()
        refreshColor()
        
        redSlider.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
        greenSlider.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
        blueSlider.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
    }
    
    private func refreshColor() {
        self.colorView.backgroundColor = self.color
        
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            
            redSlider.value = Float(fRed * 255.0)
            greenSlider.value = Float(fGreen * 255.0)
            blueSlider.value = Float(fBlue * 255.0)
            
        } else {
            
        }
    }
    
    @objc private func colorChanged() {
        self.color = UIColor.init(red: CGFloat(redSlider.value / 255.0), green: CGFloat(greenSlider.value / 255.0), blue: CGFloat(blueSlider.value / 255.0), alpha: 1.0)
        self.colorView.backgroundColor = self.color
    }
    
    
    

    
}
