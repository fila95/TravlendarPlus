//
//  Date.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 12/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation

public extension Formatter {
    
    static public let iso8601: DateFormatter = {
        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    static public let time: DateFormatter = {
        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    static public let timeShort: DateFormatter = {
        let formatter = DateFormatter()
        //        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    static public let month: DateFormatter = {
        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    static public let weekday: DateFormatter = {
        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
}


// The date components available to be retrieved or modifed
public enum DateComponentType {
    case second, minute, hour, day, weekday, nthWeekday, week, month, year
}

// The type of date that can be used for the dateFor function.
public enum DateForType {
    case startOfDay, endOfDay, startOfWeek, endOfWeek, startOfMonth, endOfMonth, tomorrow, yesterday, nearestMinute(minute:Int), nearestHour(hour:Int)
}


extension Date {
    
    public var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    // MARK: Adjust dates
    
    /// Creates a new date with adjusted components
    
    public func adjust(_ component: DateComponentType, offset:Int) -> Date {
        var dateComp = DateComponents()
        switch component {
        case .second:
            dateComp.second = offset
        case .minute:
            dateComp.minute = offset
        case .hour:
            dateComp.hour = offset
        case .day:
            dateComp.day = offset
        case .weekday:
            dateComp.weekday = offset
        case .nthWeekday:
            dateComp.weekdayOrdinal = offset
        case .week:
            dateComp.weekOfYear = offset
        case .month:
            dateComp.month = offset
        case .year:
            dateComp.year = offset
        }
        return Calendar.current.date(byAdding: dateComp, to: self)!
    }
    
    /// Return a new Date object with the new hour, minute and seconds values.
    public func adjust(hour: Int?, minute: Int?, second: Int?, day: Int? = nil, month: Int? = nil) -> Date {
        var comp = Date.components(self)
        comp.month = month ?? comp.month
        comp.day = day ?? comp.day
        comp.hour = hour ?? comp.hour
        comp.minute = minute ?? comp.minute
        comp.second = second ?? comp.second
        return Calendar.current.date(from: comp)!
    }
    
    // MARK: Date for...
    
    public func dateFor(_ type: DateForType) -> Date {
        switch type {
        case .startOfDay:
            return adjust(hour: 0, minute: 0, second: 0)
        case .endOfDay:
            return adjust(hour: 23, minute: 59, second: 59)
        case .startOfWeek:
            let offset = component(.weekday)!-1
            return adjust(.day, offset: -(offset))
        case .endOfWeek:
            let offset = 7 - component(.weekday)!
            return adjust(.day, offset: offset)
        case .startOfMonth:
            return adjust(hour: 0, minute: 0, second: 0, day: 1)
        case .endOfMonth:
            let month = (component(.month) ?? 0) + 1
            return adjust(hour: 0, minute: 0, second: 0, day: 0, month: month)
        case .tomorrow:
            return adjust(.day, offset:1)
        case .yesterday:
            return adjust(.day, offset:-1)
        case .nearestMinute(let nearest):
            let minutes = (component(.minute)! + nearest/2) / nearest * nearest
            return adjust(hour: nil, minute: minutes, second: nil)
        case .nearestHour(let nearest):
            let hours = (component(.hour)! + nearest/2) / nearest * nearest
            return adjust(hour: hours, minute: 0, second: nil)
        }
    }
    
    // MARK: Extracting components
    
    public func component(_ component:DateComponentType) -> Int? {
        let components = Date.components(self)
        switch component {
        case .second:
            return components.second
        case .minute:
            return components.minute
        case .hour:
            return components.hour
        case .day:
            return components.day
        case .weekday:
            return components.weekday
        case .nthWeekday:
            return components.weekdayOrdinal
        case .week:
            return components.weekOfYear
        case .month:
            return components.month
        case .year:
            return components.year
        }
    }
    
    // MARK: Internal Components
    
    internal static func componentFlags() -> Set<Calendar.Component> { return [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.weekOfYear, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second, Calendar.Component.weekday, Calendar.Component.weekdayOrdinal, Calendar.Component.weekOfYear] }
    internal static func components(_ fromDate: Date) -> DateComponents {
        return Calendar.current.dateComponents(Date.componentFlags(), from: fromDate)
    }
    
}

