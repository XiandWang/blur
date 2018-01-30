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
    static func success(_ message: String?, isDarkTheme: Bool) {
        guard let view = UIApplication.shared.keyWindow else {
            return
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.isUserInteractionEnabled = false
        let img = UIImage.fontAwesomeIcon(name: .checkCircle, textColor: UIColor.rgb(red: 76, green: 175, blue: 80, alpha: 1), size: CGSize(width: 52, height: 44))
        hud.customView = UIImageView(image: img)
        hud.mode = .customView
        if isDarkTheme {
            hud.bezelView.color = .black
            hud.contentColor = .white
        } else {
            hud.bezelView.color = .white
            hud.contentColor = .black
        }
        hud.bezelView.style = .solidColor
        hud.label.text = message
        hud.label.numberOfLines = 0
        hud.hide(animated: true, afterDelay: 1.5)
    }
    
    static func error(_ message: String?, isDarkTheme: Bool) {
        guard let view = UIApplication.shared.keyWindow else {
            return
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        
        hud.isUserInteractionEnabled = false
        let img = UIImage.fontAwesomeIcon(name: .timesCircle, textColor: RED_COLOR, size: CGSize(width: 52, height: 44))
        hud.customView = UIImageView(image: img)
        hud.mode = .customView
        if isDarkTheme {
            hud.bezelView.color = .black
            hud.contentColor = .white
        } else {
            hud.bezelView.color = .white
            hud.contentColor = .black
        }
        hud.bezelView.style = .solidColor
        hud.label.text = message
        hud.label.numberOfLines = 0
        hud.hide(animated: true, afterDelay: 3)
    }
    
    static func warn(_ message: String?) {
        guard let view = UIApplication.shared.keyWindow else {
            return
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        
        hud.isUserInteractionEnabled = false
        let img = UIImage.fontAwesomeIcon(name: .exclamationTriangle, textColor: UIColor.rgb(red: 255, green: 193, blue: 7, alpha: 1), size: CGSize(width: 52, height: 44))
        hud.customView = UIImageView(image: img)
        hud.mode = .customView
        hud.bezelView.color = .black
        hud.bezelView.style = .solidColor
        
        hud.contentColor = .white
        hud.label.text = message
        hud.label.numberOfLines = 0

        hud.hide(animated: true, afterDelay: 3)
    }

    
    static func progress(_ message: String?, isDarkTheme: Bool) {
        guard let view = UIApplication.shared.keyWindow else {
            return
        }
        hud = MBProgressHUD.showAdded(to: view, animated: true)
    
        hud?.alpha = 0.9
        hud?.bezelView.style = .solidColor
        if isDarkTheme {
            hud?.bezelView.color = .black
            hud?.contentColor = .white
        } else {
            hud?.bezelView.color = .white
            hud?.contentColor = .black
        }
        hud?.label.text = message
        hud?.minShowTime = 1.0
    }
    
    static func progressHidden() {
        hud?.hide(animated: true)
    }
}


extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect.init(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect.init(x: 0, y: 0, width: thickness, height: frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect.init(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
}
