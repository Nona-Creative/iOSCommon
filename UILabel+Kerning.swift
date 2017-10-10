//
//  UILabel+Kerning.swift
//  OrderIn
//
//  Created by David O'Reilly on 2017/02/03.
//  Copyright © 2017 Breakdesign. All rights reserved.
//

import Foundation

extension UILabel {
    func kern(_ kerningValue: CGFloat) {
        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: [NSAttributedStringKey.kern: kerningValue, NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: self.textColor])
    }
}
