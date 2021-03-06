//
//  UiViewControllerExtensions.swift
//
//  Created by David O'Reilly on 2016/05/05.
//  Copyright © 2016 David O'Reilly All rights reserved.
//

import Foundation
import MBProgressHUD
import ReactiveSwift

extension MBProgressHUDDelegate where Self: UIViewController {

    /**
     Show the HUD over either the view or the NavigationController view as appropriate, with preconfigured animations and look.
     Disable navigation controller gestures if needed.
     */
    func showHUD(_ message: String, onNav: Bool = true) -> MBProgressHUD {
        let hud: MBProgressHUD
        if let nav = navigationController, onNav {
            hud = MBProgressHUD(view: nav.view)
        } else {
            hud = MBProgressHUD(view: view)
        }

        // hud.backgroundView.style = .blur
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

        if let nav = navigationController, onNav {
            nav.view.addSubview(hud)
            nav.interactivePopGestureRecognizer!.isEnabled = false

            (self as UIViewController).reactive.trigger(for: #selector(UIViewController.hudWasHidden(_:))).take(first: 1).observeValues { _ in
                nav.interactivePopGestureRecognizer!.isEnabled = true
            }
        } else {
            view.addSubview(hud)
        }

        return hud
    }

    /**
     Hide the HUD with appropriate animation
     */
    func hideHUD(_ hud: MBProgressHUD, onNav: Bool = true) {
        hud.animationType = .zoomIn
        if let nav = navigationController, onNav {
            MBProgressHUD.hide(for: nav.view, animated: true)
        } else {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
}

extension UIViewController {
    // Stub to allow RAC to trigger
    @objc func hudWasHidden(_: MBProgressHUD) {
    }
}
