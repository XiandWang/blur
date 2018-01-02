//
//  XWCutGridView.swift
//  TestTimer
//
//  Created by xiandong wang on 11/9/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class XWCutGridView: UIView {

    private let TOP_LEFT_CIRCLE_TAG = 1
    private let BOTTOM_LEFT_CIRCLE_TAG = 2
    private let TOP_RIGHT_CIRCLE_TAG = 3
    private let BOTTOM_RIGHT_CIRCLE_TAG = 4
    
    var gridLayer: XWCutGridLayer!
    var clippingRect: CGRect = .zero
    
    var topLeftCircle : XWCutCircle!
    var bottomLeftCircle : XWCutCircle!
    var topRightCircle : XWCutCircle!
    var bottomRightCircle : XWCutCircle!
    
    // for pan grid view
    var isDragging = false
    var initialRect: CGRect?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    init(superView: UIView, frame: CGRect) {
        super.init(frame: frame)
        
        superView.addSubview(self)
        
        gridLayer = XWCutGridLayer(layer: self.superview?.layer as Any)
        gridLayer.frame = self.bounds
        self.layer.addSublayer(gridLayer)
        
        topLeftCircle = self.configureClippingCircle(with: TOP_LEFT_CIRCLE_TAG)
        bottomLeftCircle = self.configureClippingCircle(with: BOTTOM_LEFT_CIRCLE_TAG)
        topRightCircle = self.configureClippingCircle(with: TOP_RIGHT_CIRCLE_TAG)
        bottomRightCircle = self.configureClippingCircle(with: BOTTOM_RIGHT_CIRCLE_TAG)
    
        let gridPanGesture = UIPanGestureRecognizer(target: self, action: #selector(panGridView(sender:)))
        self.addGestureRecognizer(gridPanGesture)
        self.configureClippingRect(clippingRect: self.bounds)
        
    }
    
    func configureClippingCircle(with tag: Int) -> XWCutCircle {
        let circle = XWCutCircle(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        circle.tag = tag
       
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panCircleView(sender:)))
        circle.addGestureRecognizer(panGesture)
        
        self.superview?.addSubview(circle)
        return circle
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        topLeftCircle.removeFromSuperview()
        bottomLeftCircle.removeFromSuperview()
        topRightCircle.removeFromSuperview()
        bottomRightCircle.removeFromSuperview()
    }
    
    func setBgColor(_ color: UIColor) {
        gridLayer.bgColor = color
    }
    
    func setGridColor(_ color: UIColor) {
        gridLayer.gridColor = color
    }
    
    func configureClippingRect(clippingRect: CGRect) {
        self.clippingRect = clippingRect

        topLeftCircle.center = (self.superview?.convert(CGPoint(x: clippingRect.origin.x , y: clippingRect.origin.y )
            , from: self))!
        bottomLeftCircle.center = (self.superview?.convert(CGPoint(x: clippingRect.origin.x , y: clippingRect.origin.y + clippingRect.height ), from: self))!
        
        topRightCircle.center = (self.superview?.convert(CGPoint(x: clippingRect.origin.x + clippingRect.width  , y: clippingRect.origin.y ), from: self))!
        bottomRightCircle.center = (self.superview?.convert(CGPoint(x: clippingRect.origin.x + clippingRect.width  , y: clippingRect.origin.y + clippingRect.height), from: self))!
        
        self.gridLayer.clippingRect = clippingRect
        self.setNeedsDisplay()
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        
        gridLayer?.setNeedsDisplay()
    }
    
    @objc func panCircleView(sender: UIPanGestureRecognizer) {
        var point = sender.location(in: self)
        var rct = self.clippingRect
        
        let W = self.frame.size.width
        let H = self.frame.size.height
        var minX: CGFloat = 0
        var minY: CGFloat = 0
        var maxX: CGFloat = W
        var maxY: CGFloat = H

        guard let tag = sender.view?.tag else {
            return
        }
        switch tag {
        case TOP_LEFT_CIRCLE_TAG:
            maxX = max(rct.origin.x + rct.size.width - 0.1 * W, 0.1 * W)
            maxY = max(rct.origin.y + rct.size.height - 0.1 * H, 0.1 * H)
            
            point.x = max(minX, min(point.x, maxX));
            point.y = max(minY, min(point.y, maxY));
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x)
            rct.size.height = rct.size.height - (point.y - rct.origin.y)
            rct.origin.x = point.x
            rct.origin.y = point.y
            break
        case BOTTOM_LEFT_CIRCLE_TAG:
            maxX = max((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W)
            minY = max(rct.origin.y + 0.1 * H, 0.1 * H)
            
            point.x = max(minX, min(point.x, maxX));
            point.y = max(minY, min(point.y, maxY));
        
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x)
            rct.size.height = point.y - rct.origin.y
            rct.origin.x = point.x
            break
        case TOP_RIGHT_CIRCLE_TAG:
            minX = max(rct.origin.x + 0.1 * W, 0.1 * W)
            maxY = max((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H)
            
            point.x = max(minX, min(point.x, maxX))
            point.y = max(minY, min(point.y, maxY))
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = rct.size.height - (point.y - rct.origin.y)
            rct.origin.y = point.y
            break
        case BOTTOM_RIGHT_CIRCLE_TAG:
            minX = max(rct.origin.x + 0.1 * W, 0.1 * W)
            minY = max(rct.origin.y + 0.1 * H, 0.1 * H)
            
            point.x = max(minX, min(point.x, maxX))
            point.y = max(minY, min(point.y, maxY))
            
            rct.size.width  = point.x - rct.origin.x
            rct.size.height = point.y - rct.origin.y
            break
        default:
            break
        }
        self.configureClippingRect(clippingRect: rct)
    }
    
    @objc func panGridView(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: self)
            isDragging = self.clippingRect.contains(point)
            self.initialRect = self.clippingRect
        } else if let initialRect = self.initialRect, isDragging {
            let point = sender.translation(in: self)
            let left = min(max(initialRect.origin.x + point.x, 0), self.frame.size.width - initialRect.size.width)
            let top = min(max(initialRect.origin.y + point.y, 0), self.frame.size.height - initialRect.size.height)

            var rct = self.clippingRect
            rct.origin.x = left
            rct.origin.y = top
            self.configureClippingRect(clippingRect: rct)
        }
    }
}
