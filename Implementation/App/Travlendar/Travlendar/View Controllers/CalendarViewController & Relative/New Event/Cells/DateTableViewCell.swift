//
//  DateTableViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit
import Utilities

class DateTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setDate(date: Date) {
        self.dateLabel.text = Formatter.readableDate.string(from: date)
    }
    
    func setDuration(duration: Int) {
        let hrs = Int(Float(duration) / 60)
        self.dateLabel.text = "\(hrs):\(duration - hrs*60) minutes"
    }
    
    func setTitle(title: String) {
        self.titleLabel.text = title
    }
    
}


extension DateTableViewCell: Reusable {
    
    static var reuseId: String {
        return "dateTableViewCellID"
    }
    
    static var nib: UINib? {
        return UINib(nibName: "DateTableViewCell", bundle: Bundle.main)
    }
    
    
    
    
}
