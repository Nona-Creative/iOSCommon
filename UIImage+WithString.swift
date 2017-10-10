//
//  UIImage+WithString.swift
//
//  Created by David O'Reilly on 2015/09/11.
//  Copyright © 2015 David O'Reilly All rights reserved.
//

import UIKit

/**
 Extension to UIImage allowing the creation of images at a specific style from font glyphs
 */
extension UIImage {

    class func imageWithString(_ string: String, font: UIFont, size: CGSize, color: UIColor = UIColor.white, letterpressStyle: Bool = false) -> UIImage {

        // UIGraphicsBeginImageContext(size)
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        // Measure the string size.
        var stringSize = string.size(withAttributes: [NSAttributedStringKey.font: font])

        // Work out what it should be scaled by to get the desired size.
        var xRatio = size.width / stringSize.width
        var yRatio = size.height / stringSize.height
        var ratio = min(xRatio, yRatio)

        // Work out the point size that'll give us the desired image size, and
        // create a UIFont that size.
        var oldFontSize = font.pointSize
        var newFontSize = floor(oldFontSize * ratio)
        ratio = newFontSize / oldFontSize
        var newFont = font.withSize(newFontSize)

        // What size is the string with this new font?
        stringSize = string.size(withAttributes: [NSAttributedStringKey.font: newFont])

        // Work out where the origin of the drawn string should be to get it in the centre of the image.
        var textOrigin = CGPoint(x: (size.width - stringSize.width) / 2,
                                 y: (size.height - stringSize.height) / 2)

        // Draw the string into out image.
        string.draw(at: textOrigin, withAttributes: [NSAttributedStringKey.font: newFont, NSAttributedStringKey.foregroundColor: color])

        // We actually don't have the scaling right, because the rendered
        // string probably doesn't actually fill the entire pixel area of the
        // box we were given.  We'll use what we just drew to work out the /real/
        // size we need to draw at to fill the image.

        // First, we work out what area the drawn string /actually/ covered.

        // Get a raw bitmap of what we've drawn.
        let maskImage = UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
        let imageData = maskImage.dataProvider!.data
        let bitmap: UnsafePointer<UInt8> = CFDataGetBytePtr(imageData)
        let rowBytes = maskImage.bytesPerRow

        let scaledSize = CGSize(width: floor(size.width * scale), height: floor(size.height * scale))

        var minx = scaledSize.width, maxx: CGFloat = 0, miny = scaledSize.height, maxy: CGFloat = 0
        var rowBase = bitmap
        for y in stride(from: CGFloat(0), to: scaledSize.height, by: 1) {
            rowBase += rowBytes
            var component = rowBase + 3
            for x in stride(from: CGFloat(0), to: scaledSize.width, by: 1) {
                component += 4
                if component.pointee != 0 {
                    if x < minx {
                        minx = x
                    } else if x > maxx {
                        maxx = x
                    }
                    if y < miny {
                        miny = y
                    } else if y > maxy {
                        maxy = y
                    }
                }
            }
        }

        minx /= scale
        miny /= scale
        maxx /= scale
        maxy /= scale

        // Put the area we just found into a CGRect.
        let boundingBox = CGRect(x: minx, y: miny, width: maxx - minx + 1, height: maxy - miny + 1)

        // We're going to have to move string we're drawing as well as scale it,
        // so we work out how the origin we used to draw the string relates to the
        // 'real' origin of the filled area.
        let goodBoundingBoxOrigin = CGPoint(x: (size.width - boundingBox.size.width) / 2, y: (size.height - boundingBox.size.height) / 2)
        let textOriginXDiff = goodBoundingBoxOrigin.x - boundingBox.origin.x
        let textOriginYDiff = goodBoundingBoxOrigin.y - boundingBox.origin.y

        // Work out how much we'll need to scale by to fill the entire image.
        xRatio = size.width / boundingBox.size.width
        yRatio = size.height / boundingBox.size.height
        ratio = min(xRatio, yRatio)

        // Now, work out the font size we really need based on our scaling ratio.
        // newFontSize is still holding the size we used to draw with.
        oldFontSize = newFontSize
        newFontSize = floor(oldFontSize * ratio)
        ratio = newFontSize / oldFontSize
        newFont = font.withSize(newFontSize)

        // Work out where to place the string.
        // We offset the origin by the difference between the string-drawing origin
        // and the 'real' image origin we measured above, scaled up to the new size.
        stringSize = string.size(withAttributes: [NSAttributedStringKey.font: newFont])
        textOrigin = CGPoint(x: (size.width - stringSize.width) / 2, y: (size.height - stringSize.height) / 2)
        textOrigin.x += textOriginXDiff * ratio
        textOrigin.y += textOriginYDiff * ratio

        // Clear and draw again
        UIGraphicsGetCurrentContext()!.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        var attributes = [NSAttributedStringKey.font.rawValue: newFont, NSAttributedStringKey.foregroundColor: color] as! [NSAttributedStringKey: Any]
        if letterpressStyle {
            attributes[NSAttributedStringKey.textEffect] = NSAttributedString.TextEffectStyle.letterpressStyle
        }
        string.draw(at: textOrigin, withAttributes: attributes)

        let retImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return retImage
    }
}
