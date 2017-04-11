//
//  UIView+ExclusiveTouchRecursive.swift
//  orderin
//
//  Created by David O'Reilly on 2017/03/24.
//  Copyright © 2017 Breakdesign. All rights reserved.
//

import Foundation

extension UIView {
    func setExclusiveTouchRecursive(_ exclusive: Bool) {
        isExclusiveTouch = true
        for subView in subviews {
            subView.setExclusiveTouchRecursive(exclusive)            
        }
    }
}
