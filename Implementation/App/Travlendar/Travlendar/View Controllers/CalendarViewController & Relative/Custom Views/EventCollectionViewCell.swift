//
//  EventCollectionViewCell.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 03/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit
import Utilities

class EventCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "eventCollectionViewCell"
    
    enum Warning {
        case ok
        case warning
        case danger
        
        func color() -> UIColor {
            switch self {
            case .ok:
                return UIColor.init(hex: "00C000")
            case .warning:
                return UIColor.init(hex: "F8E71C")
            case .danger:
                return UIColor.init(hex: "FF003A")
            }
        }
    }
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue
            if newValue {
                self.alpha = 0.7
            } else if newValue == false {
                self.alpha = 1
            }
        }
    }
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            if newValue {
                self.alpha = 0.7
            } else if newValue == false {
                self.alpha = 1
            }
        }
    }

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var calendarColorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.cornerRadius = 16
        
        self.layer.borderColor = UIColor.init(hex: "B0B0B0").withAlphaComponent(0.24).cgColor
        self.layer.borderWidth = 1
        
        self.layer.shadowRadius = 19
        self.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        self.layer.shadowColor = UIColor.init(hex: "#E5E5E5").withAlphaComponent(0.3).cgColor
        
    }
    
    func setEvent(event: Event) {
        timeLabel.text = Formatter.timeShort.string(from: event.start_time)
        
        titleLabel.text = event.title
        addressLabel.text = event.address
        
        warningView.backgroundColor = Warning.ok.color()
        
        event.relativeCalendar { (calendar: Calendars?) in
            if let cal = calendar {
                self.calendarColorView.backgroundColor = UIColor.init(hex: cal.color)
            }
        }
        
    }

}
