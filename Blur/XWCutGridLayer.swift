//
//  XWCutGridLayer.swift
//  TestTimer
//
//  Created by xiandong wang on 11/9/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class XWCutGridLayer: CALayer {
    var clippingRect: CGRect //裁剪范围
    var bgColor: UIColor = .black   //背景颜色
    var gridColor: UIColor = .red //线条颜色

    
    override init(layer: Any) {
        if let layer = layer as? CALayer {
            clippingRect = layer.bounds
        } else {
            clippingRect = .zero
        }
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        let rct = self.bounds
        ctx.setFillColor(self.bgColor.cgColor)
        ctx.fill(rct)
        
        // clear the clipping rect, the rest stays in the background color
        ctx.clear(self.clippingRect)
        
        ctx.setStrokeColor(self.gridColor.cgColor)
        ctx.setLineWidth(0.8)

        
        ctx.beginPath()
        var dW: CGFloat = 0
        for _ in 0..<4 {
            ctx.move(to: CGPoint(x: self.clippingRect.origin.x+dW, y: self.clippingRect.origin.y))
            ctx.addLine(to: CGPoint(x: self.clippingRect.origin.x+dW, y: self.clippingRect.origin.y + self.clippingRect.size.height))
            dW += self.clippingRect.size.width / 3;
        }
        
        dW = 0
        
        for _ in 0..<4 {
            ctx.move(to: CGPoint(x: self.clippingRect.origin.x, y: self.clippingRect.origin.y + dW))
            ctx.addLine(to: CGPoint(x: self.clippingRect.origin.x + self.clippingRect.size.width, y: self.clippingRect.origin.y + dW))
            dW += self.clippingRect.size.height / 3;
        }
 
        ctx.strokePath()
    }
}
