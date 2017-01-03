//
//  UiViewControllerExtensions.swift
//
//  Created by David O'Reilly on 2016/05/05.
//  Copyright © 2016 David O'Reilly All rights reserved.
//

import Foundation
import MBProgressHUD
import ReactiveSwift

extension MBProgressHUDDelegate where Self : UIViewController {

    /**
     Show the HUD over either the view or the NavigationController view as appropriate, with preconfigured animations and look.
     Disable navigation controller gestures if needed.
    */
    func showHUD(_ message: String) -> MBProgressHUD {
        let hud: MBProgressHUD
        if let nav = navigationController {
            hud = MBProgressHUD.init(view: nav.view)
        } else {
            hud = MBProgressHUD.init(view: self.view)
        }
        
        //hud.backgroundView.style = .blur
        hud.backgroundView.style = .solidColor
        hud.backgroundView.color = UIColor.colorFromColor(UIColor.black, WithAlpha: 0.6)!
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor.colorFromColor(UIColor.black, WithAlpha: 0.5)!
        hud.contentColor = UIColor.white
        hud.label.text = message
        hud.animationType = .zoomOut
        hud.minShowTime = 0.5
        hud.delegate = self
        hud.show(animated: true)
        
        if let nav = navigationController {
            nav.view.addSubview(hud)
            nav.interactivePopGestureRecognizer!.isEnabled = false
            
            (self as UIViewController).reactive.trigger(for: #selector(MBProgressHUDDelegate.hudWasHidden(_:))).take(first: 1).observeValues { complete in
                nav.interactivePopGestureRecognizer!.isEnabled = true
            }
        } else {
            self.view.addSubview(hud)
        }
        
        return hud
    }
    
    /**
     Hide the HUD with appropriate animation
    */
    func hideHUD(_ hud: MBProgressHUD) {
        hud.animationType = .zoomIn
        if let nav = navigationController {
            MBProgressHUD.hide(for: nav.view, animated: true)
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}

extension UIViewController {
    //Stub to allow RAC to trigger
    func hudWasHidden(_ hud: MBProgressHUD) {
        
    }
}
