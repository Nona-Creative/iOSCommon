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
        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }

    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }

    func scaleBy(_ x: CGFloat, y: CGFloat) -> CGRect {
        return insetBy(dx: size.width - (size.width * x), dy: size.height - (size.height * y))
    }

    func innerSquare() -> CGRect {
        return CGRect(centerX: center.x, centerY: center.y, width: max(size.width, size.height), height: max(size.width, size.height))
    }

    func containingSquare() -> CGRect {
        return CGRect(centerX: center.x, centerY: center.y, width: max(size.width, size.height), height: max(size.width, size.height))
    }
}
