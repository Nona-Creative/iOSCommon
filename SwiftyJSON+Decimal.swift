//
//  SwiftyJSON+Decimal.swift
//  OrderIn
//
//  Created by David O'Reilly on 2017/10/23.
//  Copyright © 2017 Breakdesign. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    public var decimal: Decimal? {
        switch type {
        case .number:
            return Decimal(string: stringValue)
        default:
            return nil
        }
    }
}
