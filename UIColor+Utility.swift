//
//  UIColor+Utility.swift
//
//  Created by David O'Reilly on 2015/02/23.
//  Copyright (c) 2015 David O'Reilly All rights reserved.
//

import UIKit

/**
 Extension to UIColor to allow some more initialisation options, blending, and lerping.
 */
extension UIColor {
    
    convenience init(hex rgbValue: Int) {
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
            , green: CGFloat((rgbValue & 0x00FF00) >>  8)/255.0
            , blue: CGFloat((rgbValue & 0x0000FF) >>  0)/255.0
            , alpha: 1)
    }
    
    class func colorFromColor(_ color: UIColor, WithAlpha alpha: CGFloat) -> UIColor? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        }
        return nil
    }
    
    func blendWithColor(_ color2: UIColor, alpha alpha2: CGFloat) -> UIColor {
        let alpha2 = min(1.0, max(0.0, alpha2))
        let beta: CGFloat = 1.0 - alpha2
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let red: CGFloat = r1 * beta + r2 * alpha2
        let green: CGFloat = g1 * beta + g2 * alpha2
        let blue: CGFloat = b1 * beta + b2 * alpha2
        let alpha: CGFloat = a1 * beta + a2 * alpha2
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    class func lerpRGB(color1: UIColor, color2: UIColor, fraction f: CGFloat) -> UIColor {
        
        let c1 = color1.cgColor.components
        let c2 = color2.cgColor.components
        
        let r = (c1?[0])! + ((c2?[0])! - (c1?[0])!) * f
        let g = (c1?[1])! + ((c2?[1])! - (c1?[1])!) * f
        let b = (c1?[2])! + ((c2?[2])! - (c1?[2])!) * f
        let a = (c1?[3])! + ((c2?[3])! - (c1?[3])!) * f
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
