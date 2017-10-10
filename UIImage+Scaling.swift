//
//  UIImage+Scaling.swift
//
//  Created by David O'Reilly on 2015/09/11.
//  Copyright © 2015 David O'Reilly All rights reserved.
//

import UIKit

/**
 Extension to UIImage to allow easy basic scaling and cropping
 */
extension UIImage {

    func scaleTo(width: Float, height: Float, scale: Float = 0) -> UIImage {
        let newSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        UIGraphicsBeginImageContextWithOptions(newSize, false, CGFloat(scale))
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    func cropSquare() -> UIImage {
        let cropRect: CGRect
        if size.width > size.height {
            let left = (size.width - size.height) / 2
            cropRect = CGRect(x: left, y: 0, width: size.height, height: size.height)
        } else {
            let top = (size.height - size.width) / 2
            cropRect = CGRect(x: 0, y: top, width: size.width, height: size.width)
        }

        let imageRef = cgImage?.cropping(to: cropRect)
        let cropped = UIImage(cgImage: imageRef!, scale: 0, orientation: imageOrientation)
        return cropped
    }

    func scaleAndCropToSize(width targetWidth: CGFloat, targetHeight: CGFloat) -> UIImage {

        let targetSize = CGSize(width: targetWidth, height: targetHeight)
        let scaledWidth: CGFloat
        let scaledHeight: CGFloat
        let thumbnailPoint: CGPoint

        if size.equalTo(targetSize) {
            scaledWidth = targetWidth
            scaledHeight = targetHeight
            thumbnailPoint = CGPoint(x: 0.0, y: 0.0)
        } else {
            let scaleFactor: CGFloat

            let widthFactor = targetWidth / size.width
            let heightFactor = targetHeight / size.height

            if widthFactor > heightFactor {
                scaleFactor = widthFactor // scale to fit height
            } else {
                scaleFactor = heightFactor // scale to fit width
            }

            scaledWidth = size.width * scaleFactor
            scaledHeight = size.height * scaleFactor

            // center the image
            if widthFactor > heightFactor {
                thumbnailPoint = CGPoint(x: 0.0, y: (targetHeight - scaledHeight) * 0.5)
            } else if widthFactor < heightFactor {
                thumbnailPoint = CGPoint(x: (targetWidth - scaledWidth) * 0.5, y: 0.0)
            } else {
                thumbnailPoint = CGPoint(x: 0.0, y: 0.0)
            }
        }

        UIGraphicsBeginImageContext(targetSize) // this will crop

        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaledWidth
        thumbnailRect.size.height = scaledHeight

        draw(in: thumbnailRect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        // pop the context to get back to the default
        UIGraphicsEndImageContext()

        return newImage!
    }

    func pngWithSize(width: Float, height: Float) -> Data {
        let newImage = scaleTo(width: width, height: height, scale: 1)
        return UIImagePNGRepresentation(newImage)!
    }

    func jpegWithSize(width: Float, height: Float, quality: Float) -> Data {
        let newImage = scaleTo(width: width, height: height, scale: 1)
        return UIImageJPEGRepresentation(newImage, CGFloat(quality))!
    }
}
