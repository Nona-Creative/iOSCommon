//
//  Dictionary+TupleInit.swift
//  orderin
//
//  Created by David O'Reilly on 2017/07/19.
//  Copyright © 2017 Breakdesign. All rights reserved.
//

import Foundation

extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}
