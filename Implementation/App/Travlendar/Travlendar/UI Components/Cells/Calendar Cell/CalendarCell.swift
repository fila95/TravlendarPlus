//
//  CalendarCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 14/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit


class CalendarCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "calendarCell"
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                super.isHighlighted = true
                self.backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.92, alpha:1.00)
            } else if newValue == false {
                super.isHighlighted = false
                self.backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.98, alpha:1.00)
            }
        }
    }
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            if newValue {
                super.isSelected = true
                self.backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.92, alpha:1.00)
            } else if newValue == false {
                super.isSelected = false
                self.backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.98, alpha:1.00)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        colorView.layer.cornerRadius = colorView.frame.size.width/2
        self.layer.cornerRadius = 24
        super.layoutSubviews()
    }
    
    func setCalendar(c: Calendars) {
        colorView.backgroundColor = UIColor.init(hex: c.color)
        textLabel.text = c.name
    }
    
    
}
