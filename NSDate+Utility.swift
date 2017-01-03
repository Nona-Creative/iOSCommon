//
//  NSDate+Utility.swift
//
//  Created by David O'Reilly on 2015/03/22.
//  Copyright (c) 2015 David O'Reilly All rights reserved.
//

import Foundation

/**
 Utility functions for Date
 */
extension Date {
    static func dateWithYear(_ year: Int, month: Int, day: Int) -> Date {
        let calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components: DateComponents = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)!
    }
    
    func dateByAdding(hour: Int, minute: Int, second: Int) -> Date {
        let calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components: DateComponents = DateComponents()
        components.hour = hour
        components.minute = minute
        components.second = second        
        return (calendar as NSCalendar).date(byAdding: components, to: self, options: [])!
    }
}
