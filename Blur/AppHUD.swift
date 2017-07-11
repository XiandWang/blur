//
//  AppHUD.swift
//  Blur
//
//  Created by xiandong wang on 7/8/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import MBProgressHUD

private var hud: MBProgressHUD?

class AppHUD {
    static func success(_ message: String?) {
        guard let view = UIApplication.shared.keyWindow else {
            return
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.isUserInteractionEnabled = false
        hud.customView = UIImageView(image: #imageLiteral(resourceName: "Checkmark"))     
        hud.mode = .customView
        hud.label.text = message
        hud.hide(animated: true, afterDelay: 1)
    }
    
    static func error(_ message: String?) {
        guard let view = UIApplication.shared.keyWindow else {
            return
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.isUserInteractionEnabled = false
        hud.mode = .text
        hud.label.text = message
        hud.label.numberOfLines = 0
        hud.hide(animated: true, afterDelay: 2)
    }
    
    static func progress(_ message: String?) {
        guard let view = UIApplication.shared.keyWindow else {
            return
        }
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.label.text = message;
    }
    
    static func progressHidden() {
        hud?.hide(animated: true)
    }
}
