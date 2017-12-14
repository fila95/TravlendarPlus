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
