//
//  CalendarPickerView.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 27/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import DatePicker



class CalendarPickerView: UIView {
    
    enum PickerType {
        case closed
        case open
        
        func height() -> CGFloat {
            switch self {
            case .closed:
                return 100
            default:
                return 270
            }
        }
    }
    
    var type: PickerType = .closed
    
    
    private let calendarContainerView: UIView = UIView()
    private let calendarView: DPView = DPView()
    private var monthLabel: UILabel = UILabel()
    private var nextMonthButton: ArrowButton = ArrowButton()
    private var previousMonthButton: ArrowButton = ArrowButton()
    
    private var closePickerView: CalendarCloseView = CalendarCloseView()
    
    private var dragger: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    private func commonInit() {
        self.backgroundColor = UIColor.white
        
        self.layer.cornerRadius = 16
        self.layer.maskedCorners = [CACornerMask.layerMaxXMaxYCorner, CACornerMask.layerMinXMaxYCorner]
        
        self.layer.borderColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 0.24).cgColor
        self.layer.borderWidth = 1
        
        self.layer.masksToBounds = false
        
        self.layer.shadowColor = UIColor(red: 134/255, green: 134/255, blue: 134/255, alpha: 0.19).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10
        
        
        self.addSubview(calendarContainerView)
        
        self.calendarView.delegate = self
        self.calendarContainerView.addSubview(self.calendarView)
        
        self.monthLabel.font = UIFont.fonts.AvenirNext(type: .Medium, size: 17)
        self.monthLabel.numberOfLines = 0
        self.monthLabel.textColor = UIColor.darkText
        self.monthLabel.text = calendarView.presentedMonthView?.monthDescription
        self.monthLabel.textAlignment = .left
        self.calendarContainerView.addSubview(self.monthLabel)
        
        self.nextMonthButton.direction = .right
        self.nextMonthButton.addTarget(self, action: #selector(CalendarPickerView.nextMonth), for: .touchUpInside)
        self.calendarContainerView.addSubview(self.nextMonthButton)
        
        self.previousMonthButton.direction = .left
        self.previousMonthButton.addTarget(self, action: #selector(CalendarPickerView.previousMonth), for: .touchUpInside)
        self.calendarContainerView.addSubview(self.previousMonthButton)
        
        self.addSubview(closePickerView)
        
        if self.type == .open {
            self.calendarContainerView.alpha = 1.0
            self.closePickerView.alpha = 0.0
        }
        else {
            self.calendarContainerView.alpha = 0.0
            self.closePickerView.alpha = 1.0
        }
        
        // Dragger
        self.dragger.image = #imageLiteral(resourceName: "dragger")
        self.dragger.contentMode = .center
        self.dragger.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(CalendarPickerView.dragging(pan:))))
        self.dragger.isUserInteractionEnabled = true
        self.addSubview(self.dragger)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.frame = CGRect.init(x: (UIScreen.main.bounds.size.width - UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale) / 2, y: 0, width: UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale, height: self.type.height() + self.safeAreaInsets.top)
        
        
        // Calendar Opened View
        self.calendarContainerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: PickerType.open.height() + self.safeAreaInsets.top)

        self.monthLabel.frame = CGRect.init(x: 24, y: safeAreaInsets.top + 20, width: 150, height: 20)
        
        self.nextMonthButton.frame = CGRect.init(x: self.frame.size.width - 24 - 25, y: self.monthLabel.frame.origin.y - 2.5, width: 25, height: 25)
        self.previousMonthButton.frame = CGRect.init(x: self.frame.size.width - 24 - 25 - 25 - 5, y: self.monthLabel.frame.origin.y - 2.5, width: 25, height: 25)
        
        let w: CGFloat = 310
        let h: CGFloat = 230
        self.calendarView.frame = CGRect.init(x: (self.frame.size.width - w)/2, y: self.monthLabel.frame.size.height + self.monthLabel.frame.origin.y + 5, width: w, height: h)
        
        // Calendar Close View
        closePickerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: PickerType.closed.height() + self.safeAreaInsets.top)
        
        // Dragger
        dragger.frame = CGRect.init(x: 0, y: self.frame.size.height-20, width: self.frame.size.width, height: 20)
    }
    
    @objc func nextMonth() {
        calendarView.loadNextView()
    }
    
    @objc func previousMonth() {
        calendarView.loadPreviousView()
    }
    
}

extension CalendarPickerView {
    
    @objc
    func dragging(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            print("Began: " + pan.description)
            break
            
        case .changed:
            print("Changed: " + pan.description)
            break
        default:
            // Cancelled, ended
            print("Ended")
        }
    }
    
}

extension CalendarPickerView: DPViewDelegate {
    
    func didSelectDay(_ dayView: DPDayView) {
        
    }
    
    
    func didPresentOtherMonth(_ monthView: DPMonthView) {
        self.monthLabel.text = calendarView.presentedMonthView?.monthDescription
    }
    
    
    func weekdaySymbols(for calendar: Calendar) -> [String] {
        return ["S", "M", "T", "W", "T", "F", "S"]
    }
    
    
    var dateToShow: Date {
        return Date()
    }
    var firstWeekDay: DPWeekDay {
        return DPWeekDay.monday
    }
    var weekDaysViewHeightRatio: CGFloat {
        return 0.15
    }
    
    
    var fontForDayLabel: DPFont {
        return DPFont(name: "AvenirNext-Medium", size: .medium)
    }
    
    
    var colorForDayLabelInMonth: UIColor {
        return UIColor.init(hex: "#979797")
    }
    
    var colorForDayLabelOutOfMonth: UIColor {
        return UIColor.init(hex: "#E3E3E3")
    }
    
    var colorForCurrentDay: UIColor {
        return UIColor.application
    }
    var colorForSelelectedDayLabel: UIColor {
        return UIColor.white
    }
    
    
    // MARK: - WeekdaysView appearance properties
    var colorForWeekDaysViewBackground: UIColor {
        return UIColor.clear
    }
    
    var colorForWeekDaysViewText: UIColor {
        return UIColor.init(hex: "#0C0C0C")
    }
    var fontForWeekDaysViewText: DPFont {
        return DPFont.init(name: "AvenirNext-Medium", size: DPFontSize.medium)
    }
    var colorForSelectionCircleForOtherDate: UIColor {
        return UIColor.application
    }
    var colorForSelectionCircleForToday: UIColor {
        return UIColor.application
    }
}
