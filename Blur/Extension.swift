//
//  Extension.swift
//  Blur
//
//  Created by xiandong wang on 7/7/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

extension String {
    var containsWhitespace : Bool {
        return(self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension UIImage {
    
    /**
     生成指定颜色大小为1*1的图片
     
     - parameter color: 颜色
     
     - returns: 图片
     */
    static func fromColor(_ color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    
    /// 生成圆角图片
    ///
    /// - parameter imageSize:       图片大小
    /// - parameter radius:          圆角大小
    /// - parameter backgroundColor: 背景色
    /// - parameter borderWidth:     边框宽度
    /// - parameter borderColor:     边框颜色
    ///
    /// - returns: 指定大小的圆角图片
    static func roundedCorner(imageSize: CGSize, radius: CGFloat, backgroundColor: UIColor, borderWidth: CGFloat, borderColor: UIColor) -> UIImage? {
        let sizeToFit = imageSize
        let halfBorderWidth = CGFloat(borderWidth / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(sizeToFit, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        context.setLineWidth(borderWidth)
        context.setStrokeColor(borderColor.cgColor)
        context.setFillColor(backgroundColor.cgColor)
        
        let width = sizeToFit.width, height = sizeToFit.height
        // 开始坐标右边开始
        context.move(to: CGPoint(x: width - halfBorderWidth, y: radius + halfBorderWidth))
        // 右下角
        context.addArc(tangent1End: CGPoint(x: width - halfBorderWidth, y: height - halfBorderWidth), tangent2End: CGPoint(x: width - radius - halfBorderWidth, y: height - halfBorderWidth), radius: radius)
        // 左下角
        context.addArc(tangent1End: CGPoint(x: halfBorderWidth, y: height - halfBorderWidth), tangent2End: CGPoint(x: halfBorderWidth, y: height - radius - halfBorderWidth), radius: radius)
        // 左上角
        context.addArc(tangent1End: CGPoint(x: halfBorderWidth, y: halfBorderWidth), tangent2End: CGPoint(x: width - halfBorderWidth, y: halfBorderWidth), radius: radius)
        // 右上角
        context.addArc(tangent1End: CGPoint(x: width - halfBorderWidth, y: halfBorderWidth), tangent2End: CGPoint(x: width - halfBorderWidth, y: radius + halfBorderWidth), radius: radius)
        
        context.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output
    }
    
    /**
     为当前图片用指定颜色填充后取得新的图片
     
     - parameter color: 填充色
     
     - returns: 新图片
     */
    func imageWithColor(_ color: UIColor) -> UIImage? {
        guard let cgimage = cgImage else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgimage)
        color.setFill()
        context.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func fixOrientationOfImage(image: UIImage) -> UIImage? {
        if image.imageOrientation == .up {
            return image
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by:  CGFloat(Double.pi / 2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by:  -CGFloat(Double.pi / 2))
        default:
            break
        }
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue) else {
            return nil
        }
        
        context.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let CGImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: CGImage)
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hr"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s")"
    }
}

extension UITabBarController {
    func setBadges(badgeValues:[Int]){
        
        var labelExistsForIndex = [Bool]()
        
        for value in badgeValues {
            labelExistsForIndex.append(false)
        }
        
        for view in self.tabBar.subviews {
            if let v = view as? PGTabBadge {
                let badgeView = v
                let index = badgeView.tag
                
                if badgeValues[index]==0 {
                    badgeView.removeFromSuperview()
                }
                
                labelExistsForIndex[index]=true
                badgeView.text = String(badgeValues[index])
                
            }
        }
        
        for i in 0..<labelExistsForIndex.count{
            if labelExistsForIndex[i] == false {
                if badgeValues[i] > 0 {
                    addBadge(index: i, value: badgeValues[i], color:UIColor(red: 4/255, green: 110/255, blue: 188/255, alpha: 1), font: UIFont(name: "Helvetica-Light", size: 11)!)
                }
            }
        }
        
        
    }
    
    func addBadge(index:Int,value:Int, color:UIColor, font:UIFont){
        
        let itemPosition = CGFloat(index+1)
        let itemWidth:CGFloat = tabBar.frame.width / CGFloat(tabBar.items!.count)
        
        let bgColor = color
        
        let xOffset:CGFloat = 12
        let yOffset:CGFloat = -9
        
        var badgeView = PGTabBadge()
        badgeView.frame.size = CGSize(width: 17, height: 17)
        badgeView.center = CGPoint(x: itemWidth * itemPosition - (itemWidth / 2) + xOffset, y: 20+yOffset)
        badgeView.layer.cornerRadius = badgeView.bounds.width / 2
        badgeView.clipsToBounds = true
        badgeView.textColor = UIColor.white
        badgeView.textAlignment = .center
        badgeView.font = font
        badgeView.text = String(value)
        badgeView.backgroundColor = bgColor
        badgeView.tag=index
        tabBar.addSubview(badgeView)
        
    }
}

class PGTabBadge: UILabel {
    
}





