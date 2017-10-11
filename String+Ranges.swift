//
//  String+Ranges.swift
//
//  Created by David O'Reilly on 2015/09/11.
//  Copyright © 2015 David O'Reilly All rights reserved.
//

import Foundation

/**
 Convenience functions to allow subscripting of strings
 */
extension String {

    subscript(i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }

    subscript(i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript(r: Range<Int>) -> String {
        return String(self[index(startIndex, offsetBy: r.lowerBound) ... index(startIndex, offsetBy: r.upperBound)])
    }

    subscript(r: CountableRange<Int>) -> String {
        return String(self[index(startIndex, offsetBy: r.lowerBound) ..< index(startIndex, offsetBy: r.upperBound)])
    }

    subscript(r: CountableClosedRange<Int>) -> String {
        return String(self[index(startIndex, offsetBy: r.lowerBound) ... index(startIndex, offsetBy: r.upperBound)])
    }

    subscript(r: PartialRangeUpTo<Int>) -> String {
        return String(self[..<index(startIndex, offsetBy: r.upperBound)])
    }

    subscript(r: PartialRangeThrough<Int>) -> String {
        return String(self[...index(startIndex, offsetBy: r.upperBound)])
    }

    subscript(r: PartialRangeFrom<Int>) -> String {
        return String(self[index(startIndex, offsetBy: r.lowerBound)...])
    }

    func rangeFromNSRange(_ nsRange: NSRange) -> Range<String.Index>? {
        let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex)!
        let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex)!
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
            return from ..< to
        }
        return nil
    }
}
