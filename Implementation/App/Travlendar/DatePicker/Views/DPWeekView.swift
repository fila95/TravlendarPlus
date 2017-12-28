//
//  DPWeekView.swift
//  DatePicker
//
//  Created by Giovanni Filaferro on 27/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

final class DPWeekView: UIStackView {
    
    // MARK: - Properties
    private weak var datePickerView: DPView!
    private weak var monthView: DPMonthView!
    private var index: Int!
    private var dayViews: [DPDayView]!
    
    
    // MARK: - Initialization
    init(datePickerView: DPView, monthView: DPMonthView, index: Int) {
        
        self.datePickerView = datePickerView
        self.monthView = monthView
        self.index = index
        super.init(frame: .zero)
        
        self.axis = .horizontal
        self.distribution = .fillEqually
        
        //self.backgroundColor = randomColor()
        createDayViews()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Create dayView
    
    ///fills the weekView stack with dayviews
    private func createDayViews() {
        
        dayViews = [DPDayView]()
        
        for i in 0..<7 {
            
            //guard statement to prevent index getting out or range (some months need only 5 (index 4) weeks, index goes up to 5)
            guard index < monthView.monthInfo.weekDayInfo.count else { return }
            
            let dayInfo = monthView.monthInfo.weekDayInfo[index][i]
            let dayView = DPDayView(datePickerView: datePickerView, monthView: monthView, weekView: self, index: i, dayInfo: dayInfo!)
            dayViews.append(dayView)
            addArrangedSubview(dayView)
        }
        
    }
    
}

