//
//  SwiftyJSON+NSDate.swift
//
//  Created by David O'Reilly on 2016/05/12.
//  Copyright © 2016 David O'Reilly All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {

    public var date: Date? {
        switch type {
        case .string:
            return JSONNSDateFormatter.jsonDateFormatter.date(from: object as! String)
        default:
            return nil
        }
    }

    public var dateTime: Date? {
        switch type {
        case .string:
            return JSONNSDateFormatter.jsonDateTimeFormatter.date(from: object as! String)
        default:
            return nil
        }
    }
}

class JSONNSDateFormatter {

    fileprivate static var internalJsonDateFormatter: DateFormatter?
    fileprivate static var internalJsonDateTimeFormatter: DateFormatter?

    static var jsonDateFormatter: DateFormatter {
        if internalJsonDateFormatter == nil {
            internalJsonDateFormatter = DateFormatter()
            internalJsonDateFormatter!.locale = Locale(identifier: "en_US_POSIX")
            internalJsonDateFormatter!.dateFormat = "yyyy-MM-dd"
        }
        return internalJsonDateFormatter!
    }

    static var jsonDateTimeFormatter: DateFormatter {
        if internalJsonDateTimeFormatter == nil {
            internalJsonDateTimeFormatter = DateFormatter()
            internalJsonDateTimeFormatter!.locale = Locale(identifier: "en_US_POSIX")
            internalJsonDateTimeFormatter!.dateFormat = "dd/MM/yyyy - h:mm a"
        }
        return internalJsonDateTimeFormatter!
    }
}
