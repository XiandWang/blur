//
//  BadgeHelper.swift
//  Blur
//
//  Created by xiandong wang on 11/1/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class BadgeHelper {
   class func createBadge(string badgeString: String, fontSize badgeFontSize: Float, backgroundColor color: UIColor) -> UIImage {
            let textSize : CGSize = NSString(string: badgeString).size(withAttributes:[NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize:CGFloat(badgeFontSize))])
            
            // Create a frame with padding for our badge
            let height = textSize.height + 10
            var width = textSize.width + 16
            if(width < height) {
                width = height
            }
            let badgeFrame : CGRect = CGRect(x:0, y:0, width:width, height:height)
            
            let badge = CALayer()
            badge.frame = badgeFrame
            
            badge.backgroundColor = color.cgColor
            
            let badgeRadius = 20
            badge.cornerRadius = (CGFloat(badgeRadius) < (badge.frame.size.height / 2)) ? CGFloat(badgeRadius) : CGFloat(badge.frame.size.height / 2)
            
            // Draw badge into graphics context
            UIGraphicsBeginImageContextWithOptions(badge.frame.size, false, UIScreen.main.scale)
            let ctx = UIGraphicsGetCurrentContext()!
            ctx.saveGState()
            badge.render(in:ctx)
            ctx.saveGState()
            
            // Draw string into graphics context
            ctx.setBlendMode(CGBlendMode.clear)
            
            NSString(string: badgeString).draw(in:CGRect(x:8, y:5, width:textSize.width, height:textSize.height), withAttributes: [
                NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize:CGFloat(badgeFontSize)),
                NSAttributedStringKey.foregroundColor: UIColor.white
                ])
            
            let badgeImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            return badgeImage
        }
}
