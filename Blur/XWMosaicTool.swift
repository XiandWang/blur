//
//  XWMosaicTool.swift
//  TestTimer
//
//  Created by xiandong wang on 11/14/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class XWMosaicTool: XWImageToolBase {
    var mosaicView: XWMosaicView?
    var menuView: UIView?
    
    override init(editor: XWImageEditorController, toolInfo: XWImageToolInfo) {
        super.init(editor: editor, toolInfo: toolInfo)
    }
    
    override func setup() {
        mosaicView = XWMosaicView(frame: self.editor.imageView.bounds)
        guard let surfaceImage = self.editor.imageView.image else { return }
        if let mosaicView = mosaicView {
            mosaicView.surfaceImage = surfaceImage
            mosaicView.mosaicImage = mosaicImage(image: surfaceImage)
            self.editor.imageView.addSubview(mosaicView)
        }
        
        self.editor.imageView.isUserInteractionEnabled = true
        self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        self.editor.scrollView.panGestureRecognizer.delaysTouchesBegan = false;
        self.editor.scrollView.pinchGestureRecognizer?.delaysTouchesBegan = false;
    
        menuView = UIView(frame: self.editor.menuView.frame)
        if let menuView = menuView {
            menuView.backgroundColor = self.editor.menuView.backgroundColor
            self.editor.view.addSubview(menuView)
            
            menuView.transform = CGAffineTransform.init(translationX: 0, y: self.editor.view.height - menuView.top)
            UIView.animate(withDuration: 0.3) {
                menuView.transform = CGAffineTransform.identity
            }
        }
    }
    
    override func cleanup() {
        mosaicView?.removeFromSuperview()
        self.editor.imageView.isUserInteractionEnabled = false
        self.editor.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1
        
        UIView.animate(withDuration: 0.3, animations: {
            if let menuView = self.menuView {
                menuView.transform = CGAffineTransform.init(translationX: 0, y: self.editor.view.height - menuView.top)
            }
        }) { (_) in
            self.menuView?.removeFromSuperview()
        }
    }
    
    override func executeWithCompletion(completion: @escaping (UIImage?, String?) -> ()) {
        if let image = buildImage() {
            completion(image, nil)
        } else {
            completion(nil, "Error creating mosaic image")
        }
    }
    
    fileprivate func buildImage() -> UIImage? {
        if let mosaicView = mosaicView {
            UIGraphicsBeginImageContextWithOptions(mosaicView.bounds.size, false, 0)
            mosaicView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        } else {
            return nil
        }
    }
    
    fileprivate func mosaicImage(image: UIImage) -> UIImage? {
        let ciImage = CIImage(image: image)
        guard let filter = CIFilter(name: "CIPixellate") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(50, forKey: kCIInputScaleKey)
        guard let outImage = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return nil }
        let ctx = CIContext(options: nil)
        guard let cgImage = ctx.createCGImage(outImage, from: outImage.extent) else { return nil }
        let showImage = UIImage(cgImage: cgImage)
        return showImage
    }
}
