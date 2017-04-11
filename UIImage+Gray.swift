//
//  UIImage+Gray.swift
//  orderin
//
//  Created by David O'Reilly on 2017/01/23.
//  Copyright © 2017 Breakdesign. All rights reserved.
//

import Foundation

extension UIImage {

    func grayScaled() -> UIImage {
        if #available(iOS 9.0, *) { // Workaround for iOS 8 bug, creating the context crashes
            let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
            currentFilter!.setValue(CIImage(image: self), forKey: kCIInputImageKey)
            let output = currentFilter!.outputImage
            let context = CIContext(options: nil)
            let cgimg = context.createCGImage(output!, from: output!.extent)
            let processedImage = UIImage(cgImage: cgimg!)
            return processedImage
        } else {
            return self
        }
    }
}
