//
//  XWEmojiView.swift
//  Blur
//
//  Created by xiandong wang on 3/5/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit

class XWEmojiView: UIView {
    static var tempR: CGFloat = 1
    static var tempA: CGFloat = 0
    static var activeView: XWEmojiView? = nil
    private let kDeleteBtnSize: CGFloat = 32
    private let imageSize: CGFloat = 128
    var imageView = UIImageView()
    var deleteButton = UIButton()
    var scaleButton = XWScaleButton()
    
    var scale: CGFloat = 0
    var arg: CGFloat = 0
    var initialPoint: CGPoint?
    var initialScale: CGFloat = 1
    var initialArg: CGFloat = 0
    
    static func setActiveEmoticonView(view: XWEmojiView?) {
        if view != activeView {
            activeView?.setActive(false)
            activeView = view
            
            guard let activeView = activeView else { return }
            activeView.setActive(true)
            activeView.superview?.bringSubview(toFront: activeView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(image: UIImage) {   
        super.init(frame: CGRect(x: 0, y: 0, width: imageSize + kDeleteBtnSize, height: imageSize + kDeleteBtnSize))
        
        imageView = UIImageView(image: image)
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = 3;
        imageView.height = imageSize
        imageView.width = imageSize
        imageView.center = self.center;
        
        self.addSubview(imageView)
        deleteButton = UIButton(type: .custom)
        deleteButton.setImage(#imageLiteral(resourceName: "btn_delete"), for: .normal)
        deleteButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        deleteButton.center = imageView.frame.origin
        deleteButton.addTarget(self, action: #selector(clickDeleteBtn), for: .touchUpInside)
        self.addSubview(deleteButton)
    
        scaleButton = XWScaleButton(frame: CGRect(x: 0, y: 0, width: self.kDeleteBtnSize, height:  self.kDeleteBtnSize))
        scaleButton.center = CGPoint(x: imageView.width + imageView.frame.origin.x, y: imageView.height + imageView.frame.origin.y)
        scaleButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        self.addSubview(scaleButton)
        
        scale = 1
        arg = 0
        self.initGestures()
        
    }
    
    @objc func clickDeleteBtn() {
        
        var nextTarget: XWEmojiView? = nil
        guard let index = self.superview?.subviews.index(of: self) else { return }
        guard let count = self.superview?.subviews.count else { return }
        for i in (index + 1)..<count {
            if let view = self.superview?.subviews[i] as? XWEmojiView {
                nextTarget = view
                break
            }
        }
        
        if nextTarget == nil {
            for i in stride(from: index - 1, through: 0, by: -1) {
                if let view = self.superview?.subviews[i] as? XWEmojiView {
                    nextTarget = view
                    break
                }
            }
        }
        
        XWEmojiView.setActiveEmoticonView(view: nextTarget)
        self.removeFromSuperview()
    }
    
    
    func setActive(_ active: Bool ) {
        deleteButton.isHidden = !active
        scaleButton.isHidden = !active
        
        imageView.layer.borderWidth = active ? 1 / self.scale : 0
    }
    
    func setScale(_ scale: CGFloat) {
        self.scale = scale
        self.transform = CGAffineTransform.identity
        self.imageView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)

        var rct = self.frame
        rct.origin.x += (rct.size.width - (self.imageView.width + 32)) / 2
        rct.origin.y += (rct.size.height - (self.imageView.height + 32)) / 2
        rct.size.width  = self.imageView.width + 32
        rct.size.height = self.imageView.height + 32

        self.frame = rct
    
        imageView.center = CGPoint(x: rct.size.width / 2, y: rct.size.height / 2)
        //self.transform = CGAffineTransform(rotationAngle: self.arg)
        
        imageView.layer.borderWidth = 1 / self.scale
        imageView.layer.cornerRadius = 3 / self.scale
    }

    @objc func initGestures() {
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(imageDidPan)))
        scaleButton.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(scaleBtnDidPan)))
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageDidTap)))
    }
    
    
     @objc func imageDidTap(sender: UITapGestureRecognizer) {
        XWEmojiView.setActiveEmoticonView(view: self)
     }
    
    @objc func imageDidPan(sender: UIPanGestureRecognizer) {
        
        XWEmojiView.setActiveEmoticonView(view: self)
        
        let p = sender.translation(in: self.superview)
        if sender.state == .began {
            self.initialPoint = self.center
            
        }
        guard let initPoint = self.initialPoint else { return }
        self.center = CGPoint(x: initPoint.x +  p.x, y: initPoint.y + p.y)
    }
    
    @objc func scaleBtnDidPan(sender: UIPanGestureRecognizer) {        
        var p = sender.translation(in: self.superview)
        
        if sender.state == .began {
            if let initPoint = self.superview?.convert(scaleButton.center, from: scaleButton.superview) {
                self.initialPoint = initPoint
                let point = CGPoint(x: initPoint.x - self.center.x, y: initPoint.y - self.center.y)
                XWEmojiView.tempR = sqrt(point.x * point.x + point.y * point.y)
                
                XWEmojiView.tempA = atan2(p.y, p.x)
                
                initialArg = self.arg
                initialScale = self.scale
            }
        }
        
        if let initPoint = self.initialPoint {
            p = CGPoint(x: initPoint.x + p.x - self.center.x, y: initPoint.y + p.y - self.center.y)
            let R = sqrt(p.x*p.x + p.y*p.y)
            let arg = atan2(p.y, p.x)
            self.arg = initialArg + arg + XWEmojiView.tempA
            //self.arg = initialArg + arg

            self.setScale(max(initialScale * R / XWEmojiView.tempR, 0.2))
        }
    }
}
