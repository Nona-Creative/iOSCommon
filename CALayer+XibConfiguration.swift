//
//  CALayer+XibConfiguration.swift
//
//  Created by David O'Reilly on 2015/02/18.
//  Copyright (c) 2015 David O'Reilly All rights reserved.
//

import QuartzCore
import UIKit

/**
 Allow some additional configuration of layers from xibs.
 */
extension CALayer {
    @objc var borderUIColor: UIColor? {
        get {
            if let borderColor = borderColor {
                return UIColor(cgColor: borderColor)
            } else {
                return nil
            }
        }
        set(color) {
            borderColor = color?.cgColor
        }
    }

    @objc var backgroundUIColor: UIColor? {
        get {
            if let backgroundColor = backgroundColor {
                return UIColor(cgColor: backgroundColor)
            } else {
                return nil
            }
        }
        set(color) {
            backgroundColor = color?.cgColor
        }
    }
}
