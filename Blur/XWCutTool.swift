//
//  XWCutTool.swift
//  TestTimer
//
//  Created by xiandong wang on 11/14/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class XWCutTool: XWImageToolBase {
    
    var gridView: XWCutGridView?
    var menuContainer: UIView?
    
    override init(editor: XWImageEditorController, toolInfo: XWImageToolInfo) {
        super.init(editor: editor, toolInfo: toolInfo)
    }
    
    override func setup() {
        self.editor.fixZoomScaleWithAnimated(animated: true)
        if let superView = self.editor.imageView.superview {
            gridView = XWCutGridView(superView: superView, frame: self.editor.imageView.frame)
            gridView?.backgroundColor = .clear
            gridView?.setBgColor(UIColor.black.withAlphaComponent(0.8))
            gridView?.setGridColor(TINT_COLOR)
            gridView?.clipsToBounds = false
            
            menuContainer = UIView(frame: self.editor.menuView.frame)
            menuContainer?.backgroundColor = self.editor.menuView.backgroundColor
            self.editor.view.addSubview(menuContainer!)
            
            self.menuContainer?.transform = CGAffineTransform.init(translationX: 0, y: self.editor.view.height - (menuContainer?.top)!)
            UIView.animate(withDuration: 0.3, animations: {
                self.menuContainer?.transform = CGAffineTransform.identity
            })
        }
    }
    
    override func cleanup() {
        self.editor.resetZoomScaleWithAnimated(animated: true)
        gridView?.removeFromSuperview()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.menuContainer?.transform = CGAffineTransform.init(translationX: 0, y: self.editor.view.height - (self.menuContainer?.top)!)
        }) { (_) in
            self.menuContainer?.removeFromSuperview()
        }
    }
    
    override func executeWithCompletion(completion: @escaping (UIImage?, String?) -> ()) {
        if let gridView = gridView, let img = self.editor.imageView.image  {
            let zoomScale: CGFloat = self.editor.imageView.width / img.size.width

            var rct = gridView.clippingRect
            rct.size.width /= zoomScale
            rct.size.height /= zoomScale
            rct.origin.x /= zoomScale
            rct.origin.y /= zoomScale

            let origin = CGPoint(x: -rct.origin.x, y: -rct.origin.y)
            
            UIGraphicsBeginImageContextWithOptions(rct.size, false, img.scale)
            img.draw(at: origin)
            let imageFromCtx = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
    
            if let imageFromCtx = imageFromCtx {
                completion(imageFromCtx, nil)
            } else {
                completion(nil, "Cannot get image from current context")
            }
        }
    }
    
    
}
