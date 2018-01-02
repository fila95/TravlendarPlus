//
//  VPDatePickerComponent.swift
//  ViewPresenter
//
//  Created by Giovanni Filaferro on 02/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

public class VPDatePickerComponent: VPComponent {
    
    
    var date: Date = Date() {
        didSet {
            self.datePicker.setDate(date, animated: true)
        }
    }
    private var datePicker: UIDatePicker = UIDatePicker()
    
    override public func desiredheight() -> CGFloat {
        return 200
    }
    
    convenience public init(date: Date) {
        self.init(frame: CGRect.zero)
        self.date = date
        
        commonInit()
    }
    
    override public func commonInit() {
        self.datePicker.datePickerMode = .dateAndTime
        self.datePicker.setDate(self.date, animated: false)
        self.datePicker.addTarget(self, action: #selector(dateChanged(sender:)), for: .valueChanged)
        self.addSubview(self.datePicker)
    }
    
    override public func layoutSubviews() {
        self.datePicker.frame = self.bounds
    }
    
    @objc private func dateChanged(sender: UIDatePicker) {
        self.date = sender.date
    }
    
    
}

