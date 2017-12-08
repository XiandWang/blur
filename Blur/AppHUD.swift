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
        let img = UIImage.fontAwesomeIcon(name: .check, textColor: .green, size: CGSize(width: 40, height: 40))
        hud.customView = UIImageView(image: img)
        hud.mode = .customView
        hud.bezelView.color = .black
        hud.bezelView.style = .solidColor
        hud.contentColor = .white
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
        hud.bezelView.style = .solidColor
        hud.bezelView.color = .black
        hud.contentColor = .white
        hud.hide(animated: true, afterDelay: 3)
    }
    
    static func progress(_ message: String?) {
        guard let view = UIApplication.shared.keyWindow else {
            return
        }
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.alpha = 0.9
        hud?.bezelView.style = .solidColor
        hud?.bezelView.color = .black
        hud?.contentColor = .white
        hud?.label.text = message;
    }
    
    static func progressHidden() {
        hud?.hide(animated: true)
    }
}
