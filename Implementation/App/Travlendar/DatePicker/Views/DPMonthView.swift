//
//  DPMonthView.swift
//  DatePicker
//
//  Created by Giovanni Filaferro on 27/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

public final class DPMonthView: UIStackView {
    
    
    // MARK: - Properties
    
    weak var datePickerView: DPView!
    var date: Date!
    var isPresented: Bool! {
        
        willSet{
            if newValue == true{
                //this will eventually call the delegate
                datePickerView.presentedMonthView = self
            }
        }
    }
    
    public var monthDescription: String!
    var monthInfo: (monthStartDay: Date, monthEndDay: Date, numberOfWeeksInMonth: Int, weekDayInfo: [[Int:DPDay]])!
    var numberOfWeeks: Int!
    var weekViews: [DPWeekView]!
    
    // MARK: - Initialization
    
    init(datePickerView: DPView, date: Date, isPresented: Bool) {
        
        self.datePickerView = datePickerView
        self.date = date
        self.isPresented = isPresented
        super.init(frame: .zero)
        
        self.axis = .vertical
        self.distribution = .fillEqually
        
        //self.backgroundColor = randomColor()
        
        let datePickerManager = datePickerView.manager
        self.monthInfo = datePickerManager?.getMonthInfoForDate(self.date)
        self.numberOfWeeks = monthInfo.numberOfWeeksInMonth
        self.monthDescription = datePickerView.monthDescriptionForDate(self.date)
        
        //this is needed to inform the delegate about the presented month
        //the property observer isn't called on initialization
        if isPresented {
            datePickerView.presentedMonthView = self
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Reloading
    
    func reloadSubViewsWithFrame(_ frame: CGRect) {
        self.frame = frame
        
    }
    
    // MARK: - Create weekviews
    
    func createWeekViews() {
        
        weekViews = [DPWeekView]()
        
        for i in 0...5 {
            let weekView = DPWeekView(datePickerView: datePickerView, monthView: self, index: i)
            weekViews.append(weekView)
            self.addArrangedSubview(weekView)
        }
    }
    
    
    
    
}

