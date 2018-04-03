//
//  XWEmojiTool.swift
//  Blur
//
//  Created by xiandong wang on 3/4/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit

class XWEmojiTool: XWImageToolBase {
    
    var originalImage = UIImage()
    var workingView = UIView()
    var menuScroll = UIScrollView()
    
    override func setup() {
        guard let originalImg = self.editor.imageView.image else { return }
        self.originalImage = originalImg
        self.editor.fixZoomScaleWithAnimated(animated: true)
    
        menuScroll = UIScrollView(frame: self.editor.menuView.frame)
        menuScroll.backgroundColor = self.editor.menuView.backgroundColor
        menuScroll.showsVerticalScrollIndicator = false
        self.editor.view.addSubview(menuScroll)
        
        workingView = UIView(frame: self.editor.view.convert(self.editor.imageView.frame, from: self.editor.imageView.superview))
        workingView.clipsToBounds = true
        self.editor.view.addSubview(workingView)
        

        self.setEmojiMenu()
        
        menuScroll.transform = CGAffineTransform(translationX: 0, y: self.editor.view.height - menuScroll.top)
        UIView.animate(withDuration: 0.3, animations: {
            self.menuScroll.transform = CGAffineTransform.identity
        }, completion: nil)
        
    }
    
    @objc func tappedEmoticonPanel(sender: UITapGestureRecognizer) {
        guard let xwView = sender.view as? XWToolBarItem else { return }
        guard let img = xwView.iconView.image else { return }
        let view: XWEmojiView = XWEmojiView(image: img)
        
        view.center = CGPoint(x: workingView.width / 2, y: workingView.height/2)
        workingView.addSubview(view)
        
        XWEmojiView.setActiveEmoticonView(view: view)
    }
    
    func setEmojiMenu() {
        let W = 70
        let H = menuScroll.height
        var x = 0
//        for name in self.emojiNames {
//            let fullname = "emoji-\(name)"
//            let image = UIImage(named: fullname)
//            if let img = image {
//                let barItem = XWToolBarItem(frame: CGRect(x: x, y: 0, width: W, height: Int(H)), target: self, action: #selector(tappedEmoticonPanel), toolInfo: nil)
//                barItem.iconView.image = img
//                menuScroll.addSubview(barItem)
//                x += W
//            }
//        }
        for i in 1...53 {
            let image = UIImage(named: String(i))
            if let img = image {
                let barItem = XWToolBarItem(frame: CGRect(x: x, y: 0, width: W, height: Int(H)), target: self, action: #selector(tappedEmoticonPanel), toolInfo: nil)
                barItem.iconView.image = img
    
                menuScroll.addSubview(barItem)
                x += W
            }
        }
        menuScroll.contentSize = CGSize(width: max(x, Int(menuScroll.frame.size.width + 1)), height: 0)
    }
    

    
    func buildImage(image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(at: CGPoint.zero)
        
        let scale = image.size.width / workingView.width
        if let context = UIGraphicsGetCurrentContext() {
            context.scaleBy(x: scale, y: scale)
            workingView.layer.render(in: context)
            let tmp = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return tmp
        }
        return nil
    }
    

    override func cleanup() {
        self.editor.resetZoomScaleWithAnimated(animated: true)
        workingView.removeFromSuperview()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.menuScroll.transform = CGAffineTransform(translationX: 0, y: self.editor.view.height - self.menuScroll.top)
        }) { (_) in
            self.menuScroll.removeFromSuperview()
        }
    }
    
    override func executeWithCompletion(completion: @escaping (UIImage?, String?) -> ()) {
        XWEmojiView.setActiveEmoticonView(view: nil)
        
        if let image = self.buildImage(image: self.originalImage) {
            DispatchQueue.main.async {
                completion(image, nil)
            }
        } else {
            completion(nil, "Error processing image")
        }
    }
}
