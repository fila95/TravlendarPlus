//
//  CalendarPickerCollectionViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 06/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class CalendarPickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var selectionMark: UIImageView!
    
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
                self.selectionMark.isHidden = false
            } else {
                super.isSelected = false
                self.backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.98, alpha:1.00)
                self.selectionMark.isHidden = true
            }
        }
    }
    
    override func layoutSubviews() {
        colorView.layer.cornerRadius = colorView.frame.size.width/2
        self.layer.cornerRadius = 24
        super.layoutSubviews()
    }
    
    func setCalendar(c: Calendars) {
        self.colorView.backgroundColor = UIColor.init(hex: c.color)
        self.textLabel.text = c.name
    }

}


extension CalendarPickerCollectionViewCell: Reusable {
    static var reuseId: String {
        return "CalendarPickerCollectionViewCellID"
    }
    
    static var nib: UINib? {
        return UINib(nibName: "CalendarPickerCollectionViewCell", bundle: Bundle.main)
    }
    
    
    
    
}
