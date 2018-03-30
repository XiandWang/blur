//
//  XWMosaicView.swift
//  TestTimer
//
//  Created by xiandong wang on 11/10/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class XWMosaicView: UIView {

    var mosaicImage: UIImage? {
        didSet {
            if let image = mosaicImage {
                self.imageLayer.contents = image.cgImage
            }
        }
    }
    
    var surfaceImage: UIImage? {
        didSet {
            if let image = surfaceImage {
                self.surfaceImageView.image = image
            }
        }
    }
    
    lazy var surfaceImageView: UIImageView = {
        let iv = UIImageView(frame: self.bounds)
        return iv
    }()
    
    let imageLayer = CALayer()
    let shapeLayer = CAShapeLayer()
    let path = CGMutablePath()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(surfaceImageView)
        
        imageLayer.frame = self.bounds
        layer.addSublayer(imageLayer)
        
        shapeLayer.frame = self.bounds
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineWidth = 20.0
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.fillColor = nil  // must be nil
        
        layer.addSublayer(shapeLayer)
        imageLayer.mask = shapeLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            let point = touch.location(in: self)
            path.move(to: point)
            //self.shapeLayer.path = path.copy()
            self.shapeLayer.path = self.path
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        if let touch = touches.first {
            let point = touch.location(in: self)
            path.addLine(to: point)
//            if let pathCopy = path.copy() {
//                UIGraphicsBeginImageContextWithOptions(self.frame.size, true, 0)
//                let ctx = UIGraphicsGetCurrentContext()
//                ctx?.addPath(pathCopy)
//                UIColor.blue.setStroke()
//                ctx?.drawPath(using: .stroke)
//                shapeLayer.path = pathCopy
//                UIGraphicsEndImageContext()
//            }
            self.shapeLayer.path = self.path

        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
}
