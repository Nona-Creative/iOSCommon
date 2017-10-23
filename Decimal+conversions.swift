//
//  Decimal+toDouble.swift
//  OrderIn
//
//  Created by David O'Reilly on 2017/10/23.
//  Copyright © 2017 Breakdesign. All rights reserved.
//

import Foundation

extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
    var intValue: Int {
        return NSDecimalNumber(decimal: self).intValue
    }
}
