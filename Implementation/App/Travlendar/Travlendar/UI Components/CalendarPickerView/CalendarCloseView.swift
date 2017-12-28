//
//  CalendarCloseView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 27/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

class CalendarCloseView: UIView {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    
    var currentDate = Date()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        xibSetup()
        setDate(date: currentDate)
    }
    
    func setDate(date: Date) {
        currentDate = date
        let cal = Calendar.init(identifier: .gregorian)
        dayLabel.text = "\(cal.component(.day, from: currentDate))"
        monthLabel.text = "\(Formatter.month.string(from: currentDate)) \(cal.component(.year, from: currentDate))"
        weekdayLabel.text = "\(Formatter.weekday.string(from: currentDate))"
    }
    
    
}
