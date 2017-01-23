//
//  UiView+NibLoading.swift
//
//  Created by David O'Reilly on 2015/09/11.
//  Copyright © 2015 David O'Reilly All rights reserved.
//

import UIKit

protocol UIViewLoading {}
extension UIView: UIViewLoading {}

extension UIViewLoading where Self: UIView {

    // Note that this method returns an instance of type `Self`, rather than UIView
    static func loadFromNib() -> Self {
        let nibName = "\(self)".characters.split { $0 == "." }.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! Self
    }
}
