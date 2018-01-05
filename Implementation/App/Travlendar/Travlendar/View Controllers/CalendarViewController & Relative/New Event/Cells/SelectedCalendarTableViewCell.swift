//
//  SelectedCalendarTableViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 05/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class SelectedCalendarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var calendarNameLabel: UILabel!
    @IBOutlet weak var calendarColorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }
    
    func setCalendar(cal: Calendars) {
        calendarNameLabel.text = cal.name
        calendarColorView.backgroundColor = UIColor.init(hex: cal.color)
    }
    
}


extension SelectedCalendarTableViewCell: Reusable {
    
    static var reuseId: String {
        return "selectedCalendarTableViewCellID"
    }
    
    static var nib: UINib? {
        return UINib(nibName: "SelectedCalendarTableViewCell", bundle: Bundle.main)
    }
    
    
    
    
}
