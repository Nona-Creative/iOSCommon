//
//  CGRect+Utility.swift
//
//  Created by David O'Reilly on 2016/06/19.
//  Copyright © 2016 David O'Reilly All rights reserved.
//

import Foundation

/**
 Utility functions for manipulating CGRects
 */
extension CGRect {

    init(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(x: centerX - width / 2, y: centerY - height / 2, width: width, height: height)
    }

    /**
     Return a new CGRect with the origin point at (0,0)
     */
    func atOrigin() -> CGRect {
        return CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
    }

    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }

    func scaleBy(_ x: CGFloat, y: CGFloat) -> CGRect {
        return self.insetBy(dx: self.size.width - (self.size.width * x), dy: self.size.height - (self.size.height * y))
    }

    func innerSquare() -> CGRect {
        return CGRect(centerX: self.center.x, centerY: self.center.y, width: max(self.size.width, self.size.height), height: max(self.size.width, self.size.height))
    }

    func containingSquare() -> CGRect {
        return CGRect(centerX: self.center.x, centerY: self.center.y, width: max(self.size.width, self.size.height), height: max(self.size.width, self.size.height))
    }
}
