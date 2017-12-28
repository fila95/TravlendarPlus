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
    private var previousLocation: CGPoint = CGPoint.zero
    private var dragging: Bool = false
    
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
        
        self.clipsToBounds = true
        
        self.layer.shadowColor = UIColor(red: 134/255, green: 134/255, blue: 134/255, alpha: 0.19).cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), cornerRadius: 16).cgPath
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10
        
        self.calendarContainerView.layer.masksToBounds = true
        self.addSubview(self.calendarContainerView)
        
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
        
        self.closePickerView.layer.masksToBounds = true
        self.addSubview(self.closePickerView)
        
        // Dragger
        self.dragger.image = #imageLiteral(resourceName: "dragger")
        self.dragger.contentMode = .center
        self.dragger.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(CalendarPickerView.dragging(pan:))))
        self.dragger.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CalendarPickerView.tap(tap:))))
        self.dragger.isUserInteractionEnabled = true
        self.addSubview(self.dragger)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !dragging {
            reLayout()
        }
        
    }
    
    private func reLayout() {
        self.frame = CGRect.init(x: (UIScreen.main.bounds.size.width - UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale) / 2, y: 0, width: UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale, height: self.type.height() + self.safeAreaInsets.top)
        
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), cornerRadius: 16).cgPath
        
        
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
        
        if self.type == .open {
            self.calendarContainerView.alpha = 1.0
            self.closePickerView.alpha = 0.0
        }
        else {
            self.calendarContainerView.alpha = 0.0
            self.closePickerView.alpha = 1.0
        }
    }
    
    @objc func nextMonth() {
        calendarView.loadNextView()
    }
    
    @objc func previousMonth() {
        calendarView.loadPreviousView()
    }
    
    func setPickerType(type: PickerType, animated: Bool = true) {
        self.type = type
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.08, options: .curveEaseInOut, animations: {
                self.reLayout()
            }, completion: { (complete) in
                
            })
        }
        else {
            reLayout()
        }
    }
    
}

extension CalendarPickerView {
    
    @objc func tap(tap: UITapGestureRecognizer) {
        if self.type == .open {
            self.setPickerType(type: .closed)
        }
        else {
            self.setPickerType(type: .open)
        }
    }
    
    @objc func dragging(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
//            print("Began: " + pan.description)
            dragging = true
            previousLocation = pan.location(in: self)
            break
            
        case .changed:
//            print("Changed: " + pan.description)
            
            let l = pan.location(in: self)
//            print(l.y)
            
            let minHeight = PickerType.closed.height() + self.safeAreaInsets.top
            let maxHeight = PickerType.open.height() + self.safeAreaInsets.top
            
            let delta = l.y - previousLocation.y
//            print(delta)
            var newHeight = self.frame.size.height + delta
            newHeight = clamp(value: newHeight, lower: minHeight, upper: maxHeight)
            self.frame.size.height = newHeight
            
            if min(newHeight, maxHeight) / max(newHeight, maxHeight) >= min(newHeight, minHeight) / max(newHeight, minHeight) {
                // More Open than Close
                self.type = .open
            }
            else {
                // More Close than Open
                self.type = .closed
            }
            
            let percentOpen = (newHeight - minHeight) / (maxHeight - minHeight)
            closePickerView.alpha = clamp(value: (1 - percentOpen).map(from: 0.3...1.0, to: 0.0...1.0), lower: 0, upper: 1)
            calendarContainerView.alpha = clamp(value: percentOpen.map(from: 0.3...1.0, to: 0.0...1.0), lower: 0, upper: 1)
            
            previousLocation = l
            
            // Dragger
            dragger.frame = CGRect.init(x: 0, y: self.frame.size.height-20, width: self.frame.size.width, height: 20)
            
            
            break
        default:
            // Cancelled, ended
            dragging = false
            self.setPickerType(type: self.type, animated: true)
            
//            print("Ended")
        }
    }
    
}

extension CalendarPickerView: DPViewDelegate {
    
    func didSelectDay(_ dayView: DPDayView) {
        closePickerView.setDate(date: dayView.date!.dateFor(.startOfDay).addingTimeInterval(86400))
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
